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
    
    func addToPortfolio(coin: Crypto) {
        let portfolioCoin = PortfolioCoin(context: context)
        portfolioCoin.id = coin.id
        portfolioCoin.name = coin.name
        portfolioCoin.symbol = coin.symbol
        portfolioCoin.currentPrice = coin.current_price
        portfolioCoin.imageURL = coin.image
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
}
