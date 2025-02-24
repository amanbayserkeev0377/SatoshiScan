//
//  CoreDataManager.swift
//  SatoshiScan
//
//  Created by Aman on 13/2/25.
//

import CoreData
import UIKit

class CoreDataManager {
    static let shared = CoreDataManager()
    private let persistentContainer: NSPersistentContainer
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "SatoshiScanDataModel")
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
    }
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed to save Core Data: \(error.localizedDescription)")
            }
        }
    }
    
    func addToPortfolio(coin: Crypto, amount: Double) {
        let portfolioCoin = PortfolioCoin(context: context)
        portfolioCoin.id = coin.id
        portfolioCoin.name = coin.name
        portfolioCoin.symbol = coin.symbol
        portfolioCoin.currentPrice = coin.current_price
        portfolioCoin.amount = amount
        portfolioCoin.imageURL = coin.image
        saveContext()
    }
    
    func removeFromPortfolio(coin: PortfolioCoin) {
        context.delete(coin)
        saveContext()
    }
    
    func fetchPortfolio() -> [PortfolioCoin] {
        let request: NSFetchRequest<PortfolioCoin> = PortfolioCoin.fetchRequest()
        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch portfolio: \(error.localizedDescription)")
            return []
        }
    }
    
    func addToWatchList(coin: Crypto) {
        let watchlistCoin = WatchlistCoin(context: context)
        watchlistCoin.id = coin.id
        watchlistCoin.name = coin.name
        watchlistCoin.symbol = coin.symbol
        watchlistCoin.currentPrice = coin.current_price
        watchlistCoin.imageURL = coin.image
        watchlistCoin.priceChangePercentage24h = coin.price_change_percentage_24h
        watchlistCoin.previousDayPrice = coin.current_price
        saveContext()
    }
    
    func fetchWatchlist() -> [WatchlistCoin] {
        let request: NSFetchRequest<WatchlistCoin> = WatchlistCoin.fetchRequest()
        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch watchlist: \(error.localizedDescription)")
            return []
        }
    }
    
    func isInWatchlist(coin: Crypto) -> Bool {
        let request: NSFetchRequest<WatchlistCoin> = WatchlistCoin.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", coin.id)
        
        do {
            let results = try context.fetch(request)
            return !results.isEmpty
        } catch {
            print("Error checking watchlist: \(error.localizedDescription)")
            return false
        }
    }
    
    func removeFromWatchlist(coin: Crypto) {
        let request: NSFetchRequest<WatchlistCoin> = WatchlistCoin.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", coin.id)
        
        do {
            let results = try context.fetch(request)
            if let coinToDelete = results.first {
                context.delete(coinToDelete)
                saveContext()
            }
        } catch {
            print("Error removing from watchlist: \(error.localizedDescription)")
        }
    }
    
    func clearPortfolio() {
        let request: NSFetchRequest<NSFetchRequestResult> = PortfolioCoin.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        
        do {
            try context.execute(deleteRequest)
            saveContext()
        } catch {
            print("Failed to clear portfolio:", error.localizedDescription)
        }
    }
    
    func addPriceAlert(symbol: String, targetPrice: Double, imageURL: String, alertType: String) {
        let alert = PriceAlert(context: context)
        alert.symbol = symbol.uppercased()
        alert.targetPrice = targetPrice
        alert.imageURL = imageURL
        alert.alertType = alertType
        alert.isEnabled = true
        
        saveContext()
    }
    
    func fetchPriceAlerts() -> [PriceAlert] {
        let request: NSFetchRequest<PriceAlert> = PriceAlert.fetchRequest()
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching price alerts: \(error.localizedDescription)")
            return []
        }
    }
    
func removePriceAlert(alert: PriceAlert) {
        context.delete(alert)
        saveContext()
    }
    
    func deletePriceAlert(_ alert: PriceAlert) {
        let context = persistentContainer.viewContext
        context.delete(alert)
        saveContext()
    }
}
