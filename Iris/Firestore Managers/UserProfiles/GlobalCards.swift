//
//  UserProfilesUserCards.swift
//  Iris
//
//  Created by Shalin Shah on 1/8/20.
//  Copyright © 2020 Shalin Shah. All rights reserved.
//

import Foundation

class GlobalCards {
    
    var cardID: String?
    var cardName: String?
    var icon: String?
    var cardCategory: String?
    var cardDescription: String?
    var order: NSNumber?
    var createdInLat: NSNumber?
    var createdInLon: NSNumber?
    var createdInLocation: String?
    var tags: [String]?
    var usesCurrentLocation: Bool!
    var usesSpotify: Bool?
    var mapData: Bool?
    var accordionData: Bool?
    var tableData: Bool?
    var refreshRadius: NSNumber? // in meters
    var refreshTime: NSNumber? // in seconds

    var version: Int?
    var settingsGroupIDs: [String]?
    
    init(cardIDString: String? = "", cardNameString: String? = "", iconString: String? = "", cardCategoryString: String? = "", cardDescriptionString: String? = "", orderNum: NSNumber? = 0, createdInLatNum: NSNumber? = 0, createdInLonNum: NSNumber? = 0, createdInLocationString: String? = "", tagsArray: [String]? = ["none"], usesCurrentLocationBool: Bool? = false, usesSpotifyBool: Bool? = false, mapDataBool: Bool? = false, accordionDataBool: Bool? = false, tableDataBool: Bool? = false, refreshRadiusNum: NSNumber? = 0, refreshTimeNum: NSNumber? = 0, versionInt: Int? = 0, settingsGroupIDsArray: [String]? = ["none"]) {
        self.cardID = cardIDString
        self.cardName = cardNameString
        self.icon = iconString
        self.cardCategory = cardCategoryString
        self.cardDescription = cardDescriptionString
        self.createdInLat = createdInLatNum
        self.createdInLon = createdInLonNum
        self.order = orderNum
        self.createdInLocation = createdInLocationString
        self.tags = tagsArray
        self.usesCurrentLocation = usesCurrentLocationBool
        self.usesSpotify = usesSpotifyBool
        self.mapData = mapDataBool
        self.tableData = tableDataBool
        self.accordionData = accordionDataBool
        self.refreshRadius = refreshRadiusNum
        self.refreshTime = refreshTimeNum
        self.version = versionInt
        self.settingsGroupIDs = settingsGroupIDsArray
    }
}
