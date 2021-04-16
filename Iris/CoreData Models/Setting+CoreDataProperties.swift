//
//  Setting+CoreDataProperties.swift
//  
//
//  Created by Shalin Shah on 1/15/20.
//
//

import Foundation
import CoreData


extension Setting: Encodable {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Setting> {
        return NSFetchRequest<Setting>(entityName: "Setting")
    }

    @NSManaged public var settingsID: String?
    @NSManaged public var displayVal: [String]?
    @NSManaged public var selected: Bool
    @NSManaged public var type: String?
    @NSManaged public var location: [String]?
    @NSManaged public var settings_groups: Set<Setting_Group>?

    
    private enum CodingKeys: String, CodingKey { case settingsID, displayVal, selected, type, location }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(settingsID, forKey: .settingsID)
        try container.encode(displayVal, forKey: .displayVal)
        try container.encode(selected, forKey: .selected)
        try container.encode(type, forKey: .type)
        try container.encode(location, forKey: .location)
    }
    


}

extension Setting {

    @objc(addSettings_groupsObject:)
    @NSManaged public func addToSettings_groups(_ value: Setting_Group)

    @objc(removeSettings_groupsObject:)
    @NSManaged public func removeFromSettings_groups(_ value: Setting_Group)

    @objc(addSettings_groups:)
    @NSManaged public func addToSettings_groups(_ values: NSSet)

    @objc(removeSettings_groups:)
    @NSManaged public func removeFromSettings_groups(_ values: NSSet)
    
}

