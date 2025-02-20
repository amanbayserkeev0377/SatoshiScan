//
//  WebSocketManager.swift
//  SatoshiScan
//
//  Created by Aman on 14/2/25.
//

import Foundation
import NotificationCenter

protocol WebSocketManagerDelegate: AnyObject {
    func didReceivePriceUpdate(symbol: String, price: Double)
}

class WebSocketManager {
    private var webSocketTask: URLSessionWebSocketTask?
    private var reconnectAttempts = 0
    private let maxReconnectAttempts = 5
    private let reconnectDelay: TimeInterval = 5.0
    weak var delegate: WebSocketManagerDelegate?
    
    func connect(symbols: [String]) {
        
        guard webSocketTask == nil else {
            print("Websocket is already connected!")
            return
        }
        
        let streamParams = symbols.map { "\($0.lowercased())@trade" }.joined(separator: "/")
        let urlString = "wss://stream.binance.com:9443/ws/\(streamParams)"
        guard let url = URL(string: urlString) else { return }
        
        webSocketTask = URLSession.shared.webSocketTask(with: url)
        webSocketTask?.resume()
        
        receiveMessage()
        schedulePing()
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
    }
    
    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    self.handleMessage(text)
                    self.reconnectAttempts = 0
                default:
                    break
                }
                self.receiveMessage()
            case .failure(let error):
                print("WebSocket error:", error.localizedDescription)
                self.handleDisconnection()
            }
        }
    }
    
    private func handleMessage(_ text: String) {
        guard let data = text.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let symbol = json["s"] as? String,
              let priceStr = json["p"] as? String,
              let price = Double(priceStr) else { return }
        
        DispatchQueue.main.async {
            self.delegate?.didReceivePriceUpdate(symbol: symbol, price: price)
        }
    }
    
    private func handleDisconnection() {
        webSocketTask = nil
        
        guard reconnectAttempts < maxReconnectAttempts else {
            print("WebSocket failed to reconnect after \(maxReconnectAttempts) attempts")
            return
        }
        
        reconnectAttempts += 1
        print("Attempting to reconnect... (\(reconnectAttempts)/\(maxReconnectAttempts))")
        
        DispatchQueue.global().asyncAfter(deadline: .now() + reconnectDelay) { [weak self] in
            guard let self = self else { return }
            self.connect(symbols: [])
        }
    }
    
    private func checkPriceChange(symbol: String, oldPrice: Double, newPrice: Double) {
        let percentageChange = ((newPrice - oldPrice) / oldPrice) * 100
        
        if abs(percentageChange) >= 10 {
            let changeType = newPrice > oldPrice ? "increased" : "decreased"
            let message = "\(symbol.uppercased()) has \(changeType) by \(String(format: "%.2f", percentageChange))%!"
            
            sendPriceAlert(title: "Crypto Alert", body: message)
        }
    }
    
    private func sendPriceAlert(title: String, body: String) {
        print("🚀 Sending notification: \(title) - \(body)")
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error sending notification: \(error.localizedDescription)")
            } else {
                print("Notification successfully scheduled!")
            }
        }
    }
    
    private func schedulePing() {
        DispatchQueue.global().asyncAfter(deadline: .now() + 30) { [weak self] in
            guard let self = self, self.webSocketTask != nil else { return }
            
            self.webSocketTask?.sendPing { error in
                if let error = error {
                    print("Websocket ping failed:", error.localizedDescription)
                    self.handleDisconnection()
                } else {
                    print("Websocket ping sent successfully")
                    self.schedulePing()
                }
            }
        }
    }
    
    private func checkPriceAlerts(symbol: String, newPrice: Double) {
        let alerts = CoreDataManager.shared.fetchPriceAlerts()
        
        for alert in alerts {
            guard let alertSymbol = alert.symbol?.lowercased() else { continue }
            if alertSymbol == symbol.lowercased() {
                sendPriceAlert(title: "Price Alert", body: "\(symbol.uppercased()) reached $\(alert.targetPrice)!")
                CoreDataManager.shared.removePriceAlert(alert: alert)
            }
        }
        
        func didReceivePriceUpdate(symbol: String, price: Double) {
            checkPriceAlerts(symbol: symbol, newPrice: price)
            
            DispatchQueue.main.async {
                self.delegate?.didReceivePriceUpdate(symbol: symbol, price: price)
            }
        }
    }
}
