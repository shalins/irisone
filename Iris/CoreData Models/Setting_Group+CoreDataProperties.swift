//
//  Setting_Group+CoreDataProperties.swift
//  
//
//  Created by Shalin Shah on 1/15/20.
//
//

import Foundation
import CoreData


extension Setting_Group: Encodable {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Setting_Group> {
        return NSFetchRequest<Setting_Group>(entityName: "Setting_Group")
    }

    @NSManaged public var settingsGroupID: String?
    @NSManaged public var globalSettingsGroupID: String?
    @NSManaged public var tag: String?
    @NSManaged public var selectorFormat: String?
    @NSManaged public var selectorEditable: Bool
    @NSManaged public var selectorRemovable: Bool
    @NSManaged public var selectorHeader: [String]?
    @NSManaged public var modifierFormat: String?
    @NSManaged public var modifierEditable: Bool
    @NSManaged public var modifierRemovable: Bool
    @NSManaged public var modifierHeader: [String]?
    @NSManaged public var settings: Set<Setting>?
    @NSManaged public var cards: Set<Card>?
    
    private enum CodingKeys: String, CodingKey { case settingsGroupID, globalSettingsGroupID, tag, selectorFormat, selectorEditable, selectorRemovable, selectorHeader, modifierFormat, modifierEditable, modifierRemovable, modifierHeader, settings, cards }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(settingsGroupID, forKey: .settingsGroupID)
        try container.encode(globalSettingsGroupID, forKey: .globalSettingsGroupID)
        try container.encode(tag, forKey: .tag)
        try container.encode(selectorFormat, forKey: .selectorFormat)
        try container.encode(selectorEditable, forKey: .selectorEditable)
        try container.encode(selectorRemovable, forKey: .selectorRemovable)
        try container.encode(selectorHeader, forKey: .selectorHeader)
        try container.encode(modifierFormat, forKey: .modifierFormat)
        try container.encode(modifierEditable, forKey: .modifierEditable)
        try container.encode(modifierRemovable, forKey: .modifierRemovable)
        try container.encode(modifierHeader, forKey: .modifierHeader)
    }

}


// MARK: Generated accessors for cards
extension Setting_Group {

    @objc(addCardsObject:)
    @NSManaged public func addToCards(_ value: Card)

    @objc(removeCardsObject:)
    @NSManaged public func removeFromCards(_ value: Card)

    @objc(addCards:)
    @NSManaged public func addToCards(_ values: NSSet)

    @objc(removeCards:)
    @NSManaged public func removeFromCards(_ values: NSSet)

}

// MARK: Generated accessors for settings
extension Setting_Group {

    @objc(addSettingsObject:)
    @NSManaged public func addToSettings(_ value: Setting)

    @objc(removeSettingsObject:)
    @NSManaged public func removeFromSettings(_ value: Setting)

    @objc(addSettings:)
    @NSManaged public func addToSettings(_ values: NSSet)

    @objc(removeSettings:)
    @NSManaged public func removeFromSettings(_ values: NSSet)

}

