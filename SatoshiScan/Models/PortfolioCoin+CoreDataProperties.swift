//
//  PortfolioCoin+CoreDataProperties.swift
//  SatoshiScan
//
//  Created by Aman on 14/2/25.
//

import Foundation
import CoreData

extension PortfolioCoin {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<PortfolioCoin> {
        return NSFetchRequest<PortfolioCoin>(entityName: "PortfolioCoin")
    }
    
    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var symbol: String?
    @NSManaged public var currentPrice: Double
    @NSManaged public var imageURL: String?
}

extension PortfolioCoin: Identifiable { }
