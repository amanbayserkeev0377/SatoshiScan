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
    
    func fetchCryptoData() {
        CoinGeckoAPI.fetchCoins { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let coins):
                    self?.coins = coins
                    self?.onDataUpdated?()
                case .failure(let error):
                    print("Error fetching data: \(error.localizedDescription)")
                }
            }
        }
    }
}
