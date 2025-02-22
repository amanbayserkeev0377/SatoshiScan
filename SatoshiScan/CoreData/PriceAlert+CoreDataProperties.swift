//
//  PriceAlert+CoreDataProperties.swift
//  SatoshiScan
//
//  Created by Aman on 22/2/25.
//
//

import Foundation
import CoreData


extension PriceAlert {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PriceAlert> {
        return NSFetchRequest<PriceAlert>(entityName: "PriceAlert")
    }

    @NSManaged public var imageURL: String?
    @NSManaged public var isEnabled: Bool
    @NSManaged public var symbol: String?
    @NSManaged public var targetPrice: Double

}

extension PriceAlert : Identifiable {

}
