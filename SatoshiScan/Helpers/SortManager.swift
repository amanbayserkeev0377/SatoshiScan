//
//  SortManager.swift
//  SatoshiScan
//
//  Created by Aman on 20/2/25.
//

import Foundation

enum SortOption {
    case nameAscending
    case nameDescending
    case priceAscending
    case priceDescending
    case changeAscending
    case changeDescending
    case amountAscending
    case amountDescending
}

class SortManager {
    static func sortCoins<T: SortableCrypto>(_ coins: inout [T], by option: SortOption) {
        switch option {
        case .nameAscending:
            if var portfolioCoins = coins as? [PortfolioCoin] {
                portfolioCoins.sort { $0.name < $1.name }
                coins = portfolioCoins as! [T]
            } else {
                coins.sort { $0.name < $1.name }
            }
        case .nameDescending:
            if var portfolioCoins = coins as? [PortfolioCoin] {
                portfolioCoins.sort { $0.name > $1.name }
                coins = portfolioCoins as! [T]
            } else {
                coins.sort { $0.name > $1.name }
            }
        case .priceAscending:
            coins.sort { $0.currentPrice < $1.currentPrice }
        case .priceDescending:
            coins.sort { $0.currentPrice > $1.currentPrice }
        case .changeAscending:
            coins.sort { ($0.priceChange ?? 0) < ($1.priceChange ?? 0) }
        case .changeDescending:
            coins.sort { ($0.priceChange ?? 0) > ($1.priceChange ?? 0) }
        case .amountAscending:
            if var portfolioCoins = coins as? [PortfolioCoin] {
                portfolioCoins.sort { $0.amount < $1.amount }
                coins = portfolioCoins as! [T]
            }
        case .amountDescending:
            if var portfolioCoins = coins as? [PortfolioCoin] {
                portfolioCoins.sort { $0.amount > $1.amount }
                coins = portfolioCoins as! [T]
            }
        }
    }
}

protocol SortableCrypto {
    
    var name: String { get }
    var currentPrice: Double { get }
    var priceChange: Double? { get }
}


extension Crypto: SortableCrypto {
    var currentPrice: Double { return current_price }
    var priceChange: Double? { return price_change_percentage_24h }
}

