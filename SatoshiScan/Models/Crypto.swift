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
    let current_price: Double
    let image: String
}
