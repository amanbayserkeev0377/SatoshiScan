//
//  Crypto.swift
//  SatoshiScan
//
//  Created by Aman on 13/2/25.
//

import Foundation

struct Crypto: Decodable {
    let id: String
    let name: String
    let symbol: String
    var current_price: Double
    let image: String
    let price_change_percentage_24h: Double
}
