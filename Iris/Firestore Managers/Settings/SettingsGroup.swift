//
//  SettingsGroup.swift
//  Iris
//
//  Created by Shalin Shah on 1/15/20.
//  Copyright © 2020 Shalin Shah. All rights reserved.
//

import Foundation

import Foundation

class SettingsGroup {
    
    var settingsGroupID: String?
    var tag: String?
    var selectorFormat: String?
    var selectorEditable: Bool?
    var selectorRemovable: Bool?
    var selectorHeader: [String]?
    var modifierFormat: String?
    var modifierEditable: Bool?
    var modifierRemovable: Bool?
    var modifierHeader: [String]?
    
    init(settingsGroupIDString: String? = "", tagString: String? = "", selectorFormatString: String? = "", selectorEditableBool: Bool? = false, selectorRemovableBool: Bool? = false, selectorHeaderArray: [String]? = ["none"], modifierFormatString: String? = "", modifierEditableBool: Bool? = false, modifierRemovableBool: Bool? = false, modifierHeaderArray: [String]? = ["none"]) {
        self.settingsGroupID = settingsGroupIDString
        self.tag = tagString
        self.selectorFormat = selectorFormatString
        self.selectorEditable = selectorEditableBool
        self.selectorRemovable = selectorRemovableBool
        self.selectorHeader = selectorHeaderArray
        self.modifierFormat = modifierFormatString
        self.modifierEditable = modifierEditableBool
        self.modifierRemovable = modifierRemovableBool
        self.modifierHeader = modifierHeaderArray
    }
}
