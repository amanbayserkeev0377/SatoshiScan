//
//  CryptoViewModel.swift
//  SatoshiScan
//
//  Created by Aman on 12/2/25.
//

import Foundation

class CryptoViewModel {
    var coins: [Crypto] = []
    var onDataUpdated: (() -> Void)?
    private let webSocketManager = WebSocketManager()
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(currencyChanged), name: Notification.Name("CurrencyChanged"), object: nil)
    }
    
    @objc private func currencyChanged() {
        fetchCryptoData()
    }
    
    func fetchCryptoData() {
        CoinGeckoAPI.fetchCoins { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let coins):
                    self?.coins = coins
                    self?.onDataUpdated?()
                    self?.startWebSocket()
                case .failure(let error):
                    print("Error fetching data: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func startWebSocket() {
        let symbols = coins.map { $0.symbol.uppercased() + "USDT" }
        webSocketManager.delegate = self
        webSocketManager.connect(symbols: symbols)
    }
}

// MARK: - WebSocketManagerDelegate
extension CryptoViewModel: WebSocketManagerDelegate {
    func didReceivePriceUpdate(symbol: String, price: Double) {
        if let index = coins.firstIndex(where: { "\($0.symbol.lowercased())usdt" == symbol.lowercased() }) {
            coins[index].current_price = price
            
            DispatchQueue.main.async {
                self.onDataUpdated?()
            }
        }
    }
}
