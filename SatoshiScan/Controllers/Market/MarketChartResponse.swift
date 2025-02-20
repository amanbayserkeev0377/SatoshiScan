//
//  MarketChartResponse.swift
//  SatoshiScan
//
//  Created by Aman on 13/2/25.
//

import Foundation

struct MarketChartResponse: Decodable {
    let prices: [[Double]]
}
