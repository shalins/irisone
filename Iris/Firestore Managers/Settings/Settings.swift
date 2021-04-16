//
//  Settings.swift
//  Iris
//
//  Created by Shalin Shah on 1/15/20.
//  Copyright © 2020 Shalin Shah. All rights reserved.
//

import Foundation

class Settings {
    
    var settingsID: String?
    var displayVal: [String]?
    var selected: Bool?
    var type: String?
    var location: [String]?
    
    init(settingsIDString: String? = "", displayValArray: [String]? = ["none"], selectedBool: Bool? = false, typeString: String? = "", locationArray: [String]? = ["none"]) {
        self.settingsID = settingsIDString
        self.displayVal = displayValArray
        self.selected = selectedBool
        self.type = typeString
        self.location = locationArray
    }
}

