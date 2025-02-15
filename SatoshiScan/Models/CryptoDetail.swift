//
//  CryptoDetail.swift
//  SatoshiScan
//
//  Created by Aman on 15/2/25.
//

import Foundation

struct CryptoDetail: Decodable {
    let id: String
    let name: String
    let symbol: String
    let market_data: MarketData
    
    struct MarketData: Decodable {
        let currect_price: [String: Double]?
        let price_change_percentage_24h: Double?
        let market_cap: [String: Double]?
        let total_volume: [String: Double]?
    }
}
