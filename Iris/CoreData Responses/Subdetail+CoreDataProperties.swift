//
//  Subdetail+CoreDataProperties.swift
//  
//
//  Created by Shalin Shah on 1/26/20.
//
//

import Foundation
import CoreData


extension Subdetail {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Subdetail> {
        return NSFetchRequest<Subdetail>(entityName: "Subdetail")
    }

    @NSManaged public var subdetailID: String?
    @NSManaged public var timestamp: Double
    @NSManaged public var order: Double
    @NSManaged public var richLabel: [String: String]?
    @NSManaged public var richSublabel: [String: String]?
    @NSManaged public var richDescription: [String: String]?
    @NSManaged public var richSmallLabelOne: [String: String]?
    @NSManaged public var richSmallLabelTwo: [String: String]?
    @NSManaged public var richMetric: [String: String]?
    @NSManaged public var richMetricUnits: [String: String]?
    @NSManaged public var richMetricTwo: [String: String]?
    @NSManaged public var richMetricUnitsTwo: [String: String]?
    @NSManaged public var selected: Bool
    @NSManaged public var detail: Detail?

}
