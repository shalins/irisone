//
//  Detail+CoreDataProperties.swift
//  
//
//  Created by Shalin Shah on 1/26/20.
//
//

import Foundation
import CoreData


extension Detail {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Detail> {
        return NSFetchRequest<Detail>(entityName: "Detail")
    }

    @NSManaged public var detailID: String?
    @NSManaged public var richLabel: [String: String]?
    @NSManaged public var richSmallLabelOne: [String: String]?
    @NSManaged public var richSmallLabelTwo: [String: String]?
    @NSManaged public var lat: Double
    @NSManaged public var lon: Double
    @NSManaged public var order: Double
    @NSManaged public var response: Response?
    @NSManaged public var subdetails: Set<Subdetail>?

}

// MARK: Generated accessors for subdetails
extension Detail {

    @objc(addSubdetailsObject:)
    @NSManaged public func addToSubdetails(_ value: Subdetail)

    @objc(removeSubdetailsObject:)
    @NSManaged public func removeFromSubdetails(_ value: Subdetail)

    @objc(addSubdetails:)
    @NSManaged public func addToSubdetails(_ values: NSSet)

    @objc(removeSubdetails:)
    @NSManaged public func removeFromSubdetails(_ values: NSSet)

}
