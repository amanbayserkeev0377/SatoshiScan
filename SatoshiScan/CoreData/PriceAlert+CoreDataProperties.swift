//
//  PriceAlert+CoreDataProperties.swift
//  SatoshiScan
//
//  Created by Aman on 22/2/25.
//
//

import Foundation
import CoreData

public enum AlertType: String {
    case above = "above"
    case below = "below"
}

extension PriceAlert {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PriceAlert> {
        return NSFetchRequest<PriceAlert>(entityName: "PriceAlert")
    }

    @NSManaged public var imageURL: String?
    @NSManaged public var isEnabled: Bool
    @NSManaged public var symbol: String?
    @NSManaged public var targetPrice: Double
    @NSManaged public var alertType: String?

}

extension PriceAlert : Identifiable {

}
