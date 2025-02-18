//
//  WatchlistCoin+CoreDataProperties.swift
//  SatoshiScan
//
//  Created by Aman on 17/2/25.
//
//

import Foundation
import CoreData


extension WatchlistCoin {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WatchlistCoin> {
        return NSFetchRequest<WatchlistCoin>(entityName: "WatchlistCoin")
    }

    @NSManaged public var amount: Double
    @NSManaged public var currentPrice: Double
    @NSManaged public var id: String?
    @NSManaged public var imageURL: String?
    @NSManaged public var name: String?
    @NSManaged public var symbol: String?

}

extension WatchlistCoin : Identifiable {

}
