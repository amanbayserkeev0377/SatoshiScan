//
//  WebSocketManager.swift
//  SatoshiScan
//
//  Created by Aman on 14/2/25.
//

import Foundation

protocol WebSocketManagerDelegate: AnyObject {
    func didReceivePriceUpdate(symbol: String, price: Double)
}

class WebSocketManager {
    private var webSocketTask: URLSessionWebSocketTask?
    weak var delegate: WebSocketManagerDelegate?
    
    func connect(symbols: [String]) {
        let streamParams = symbols.map { "\($0.lowercased())@trade" }.joined(separator: "/")
        let urlString = "wss://stream.binance.com:9443/ws/\(streamParams)"
        guard let url = URL(string: urlString) else { return }
        
        webSocketTask = URLSession.shared.webSocketTask(with: url)
        webSocketTask?.resume()
        
        receiveMessage()
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
    }
    
    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    self?.handleMessage(text)
                default:
                    break
                }
                self?.receiveMessage()
            case .failure(let error):
                print("WebSocket error:", error.localizedDescription)
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
}
