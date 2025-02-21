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
    @NSManaged public var rawName: String?
    @NSManaged public var symbol: String?
    @NSManaged public var currentPrice: Double
    @NSManaged public var imageURL: String?
    @NSManaged public var amount: Double
}

extension PortfolioCoin: Identifiable { }

// MARK: - Conformance to SortableCrypto
extension PortfolioCoin: SortableCrypto {
    
    public var name: String {
        get { rawName ?? "Unknown" }
        set { rawName = newValue }
    }
    
    public var priceChange: Double? {
        return nil
    }
}
