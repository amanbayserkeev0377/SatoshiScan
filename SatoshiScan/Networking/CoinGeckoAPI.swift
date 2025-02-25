//
//  CoinGeckoAPI.swift
//  SatoshiScan
//
//  Created by Aman on 12/2/25.
//

import Foundation
import Alamofire
import DGCharts

struct CryptoAPIResponse: Decodable {
    let id: String
    let name: String
    let symbol: String
    let current_price: Double
    let image: String
    let price_change_percentage_24h: Double
}

struct CoinGeckoAPI {
    static let baseURL = "https://api.coingecko.com/api/v3"
    
    enum Endpoint: String {
        case coinsList = "/coins/markets"
        case marketChart = "/coins/%@/market_chart"
    }
    
    static func fetchCoins(completion: @escaping (Result<[Crypto], Error>) -> Void) {
        let selectedCurrency = UserDefaults.standard.string(forKey: "selectedCurrency") ?? "USD"
        
        let url = baseURL + Endpoint.coinsList.rawValue
        let parameters: [String: Any] = [
            "vs_currency": selectedCurrency.lowercased(),
            "order": "market_cap_desc",
            "per_page": 20,
            "page": 1,
            "sparkline": false,
            "price_change_percentage": "24h"
        ]
        
        AF.request(url, parameters: parameters).responseDecodable(of: [CryptoAPIResponse].self) { response in
            switch response.result {
            case .success(let coinsData):
                let coins = coinsData.map { apiCoin in
                    Crypto(
                        id: apiCoin.id,
                        name: apiCoin.name,
                        symbol: apiCoin.symbol,
                        current_price: apiCoin.current_price,
                        image: apiCoin.image,
                        price_change_percentage_24h: apiCoin.price_change_percentage_24h
                    )
                }
                completion(.success(coins))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    static func fetchMarketChart(for coinID: String, completion: @escaping (Result<[ChartDataEntry], Error>) -> Void) {
        let url = String(format: baseURL + Endpoint.marketChart.rawValue, coinID)
        let parameters: [String: Any] = [
            "vs_currency": "usd",
            "days": 7,
            "interval": "daily"
        ]
        
        AF.request(url, parameters: parameters).responseDecodable(of: MarketChartResponse.self) { response in
            switch response.result {
            case .success(let data):
                let chartEntries = data.prices.map { ChartDataEntry(x: $0[0] / 1000, y: $0[1]) }
                    completion(.success(chartEntries))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

// MARK: - Fetch Crypto Detail
extension CoinGeckoAPI {
    static func fetchCryptoDetail(for coinID: String, completion: @escaping (Result<CryptoDetail, Error>) -> Void) {
        let url = "\(baseURL)/coins/\(coinID)?localization=false&tickers=false&market_data=true&community_data=false&developer_data=false"
        
        AF.request(url).responseDecodable(of: CryptoDetail.self) { response in
            if let statusCode = response.response?.statusCode, statusCode == 429 {
                print("API Rate Limit Exceeded. Waiting before retrying...")
                DispatchQueue.global().asyncAfter(deadline: .now() + 10) {
                    fetchCryptoDetail(for: coinID, completion: completion)
                }
                return
            }
            
            switch response.result {
            case .success(let detail):
                completion(.success(detail))
            case .failure(let error):
                print("Error decoding JSON:", error.localizedDescription)
                completion(.failure(error))
            }
        }
    }
}
