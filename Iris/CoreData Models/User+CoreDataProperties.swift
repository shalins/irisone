//
//  User+CoreDataProperties.swift
//  
//
//  Created by Shalin Shah on 1/14/20.
//
//

import Foundation
import CoreData


extension User: Encodable {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var userID: String?
    @NSManaged public var phoneNum: String?
    @NSManaged public var firstName: String?
    @NSManaged public var lastName: String?
    @NSManaged public var pushToken: String?
    @NSManaged public var timeJoined: Double
    @NSManaged public var fullName: String?
    @NSManaged public var location: [Double]?
    @NSManaged public var spotify: String?
    @NSManaged public var responseRefreshIDs: [String]?

    @NSManaged public var oldResponseID: String?
    @NSManaged public var cards: Set<Card>?
    
    private enum CodingKeys: String, CodingKey { case pushToken, location, oldResponseID, spotify, responseRefreshIDs }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(pushToken, forKey: .pushToken)
        try container.encode(location, forKey: .location)
        try container.encode(oldResponseID, forKey: .oldResponseID)
        try container.encode(spotify, forKey: .spotify)
        try container.encode(responseRefreshIDs, forKey: .responseRefreshIDs)
    }
}

// MARK: Generated accessors for cards
extension User {

    @objc(addCardsObject:)
    @NSManaged public func addToCards(_ value: Card)

    @objc(removeCardsObject:)
    @NSManaged public func removeFromCards(_ value: Card)

    @objc(addCards:)
    @NSManaged public func addToCards(_ values: Set<Card>)

    @objc(removeCards:)
    @NSManaged public func removeFromCards(_ values: Set<Card>)

}
