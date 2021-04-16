//
//  Response+CoreDataProperties.swift
//  
//
//  Created by Shalin Shah on 1/26/20.
//
//

import Foundation
import CoreData


extension Response {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Response> {
        return NSFetchRequest<Response>(entityName: "Response")
    }

    @NSManaged public var responseID: String?
    @NSManaged public var sentenceFormat: [String]?
    @NSManaged public var sentence: [String]?
    @NSManaged public var alerts: [String]?
    @NSManaged public var responseURL: String?
    @NSManaged public var responseURLType: String?
    @NSManaged public var details: Set<Detail>?
    @NSManaged public var card: Card?

}

// MARK: Generated accessors for details
extension Response {

    @objc(addDetailsObject:)
    @NSManaged public func addToDetails(_ value: Detail)

    @objc(removeDetailsObject:)
    @NSManaged public func removeFromDetails(_ value: Detail)

    @objc(addDetails:)
    @NSManaged public func addToDetails(_ values: NSSet)

    @objc(removeDetails:)
    @NSManaged public func removeFromDetails(_ values: NSSet)

}
