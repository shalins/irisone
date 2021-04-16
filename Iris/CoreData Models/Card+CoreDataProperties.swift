//
//  Card+CoreDataProperties.swift
//  
//
//  Created by Shalin Shah on 1/15/20.
//
//

import Foundation
import CoreData


extension Card: Encodable {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Card> {
        return NSFetchRequest<Card>(entityName: "Card")
    }

    @NSManaged public var cardID: String?
    @NSManaged public var globalCardID: String?
    @NSManaged public var cardName: String?
    @NSManaged public var icon: String?
    @NSManaged public var cardCategory: String?
    @NSManaged public var cardDescription: String?
    @NSManaged public var createdInLat: Double
    @NSManaged public var createdInLon: Double
    @NSManaged public var createdInLocation: String?
    @NSManaged public var tags: [String]?
    @NSManaged public var usesCurrentLocation: Bool
    @NSManaged public var usesSpotify: Bool
    @NSManaged public var mapData: Bool
    @NSManaged public var accordionData: Bool
    @NSManaged public var tableData: Bool
    @NSManaged public var refreshRadius: Double
    @NSManaged public var refreshTime: Double
    @NSManaged public var version: Int16
    @NSManaged public var settingsGroupIDs: [String]?
    @NSManaged public var lastTimestamp: Double
    @NSManaged public var lastLocationLat: Double
    @NSManaged public var lastLocationLon: Double
    @NSManaged public var orderNumber: Int16

    @NSManaged public var users: User?
    @NSManaged public var settings_groups: Set<Setting_Group>?
    @NSManaged public var response: Response?

    
    private enum CodingKeys: String, CodingKey { case cardID, globalCardID, cardName, icon, cardCategory, cardDescription, createdInLat, createdInLon, createdInLocation, tags, usesCurrentLocation, usesSpotify, mapData, accordionData, tableData, refreshRadius, refreshTime, version, settingsGroupIDs }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(cardID, forKey: .cardID)
        try container.encode(globalCardID, forKey: .globalCardID)
        try container.encode(cardName, forKey: .cardName)
        try container.encode(icon, forKey: .icon)
        try container.encode(cardCategory, forKey: .cardCategory)
        try container.encode(cardDescription, forKey: .cardDescription)
        try container.encode(cardDescription, forKey: .cardDescription)
        try container.encode(createdInLat, forKey: .createdInLat)
        try container.encode(createdInLon, forKey: .createdInLon)
        try container.encode(createdInLocation, forKey: .createdInLocation)
        try container.encode(tags, forKey: .tags)
        try container.encode(usesCurrentLocation, forKey: .usesCurrentLocation)
        try container.encode(usesSpotify, forKey: .usesSpotify)
        try container.encode(mapData, forKey: .mapData)
        try container.encode(accordionData, forKey: .accordionData)
        try container.encode(tableData, forKey: .tableData)
        try container.encode(refreshRadius, forKey: .refreshRadius)
        try container.encode(refreshTime, forKey: .refreshTime)
        try container.encode(version, forKey: .version)
        try container.encode(settingsGroupIDs, forKey: .settingsGroupIDs)
    }

}

// MARK: Generated accessors for settings_groups
extension Card {

    @objc(addSettings_groupsObject:)
    @NSManaged public func addToSettings_groups(_ value: Setting_Group)

    @objc(removeSettings_groupsObject:)
    @NSManaged public func removeFromSettings_groups(_ value: Setting_Group)

    @objc(addSettings_groups:)
    @NSManaged public func addToSettings_groups(_ values: NSSet)

    @objc(removeSettings_groups:)
    @NSManaged public func removeFromSettings_groups(_ values: NSSet)
}
