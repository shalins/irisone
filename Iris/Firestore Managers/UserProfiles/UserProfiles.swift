//
//  UserProfiles.swift
//  Iris
//
//  Created by Shalin Shah on 1/7/20.
//  Copyright © 2020 Shalin Shah. All rights reserved.
//

import Foundation

class UserProfiles {
    var firstName: String?
    var lastName: String?
    var fullName: String?
    var phoneNum: String?
    var userID: String?
    var timeJoined: NSNumber?
    var pushToken: String?
    
    init(firstNameString: String? = "", lastNameString: String? = "", fullNameString: String? = "", phoneNumString: String? = "", userIDString: String? = "", timeJoinedNum: NSNumber? = 0, pushTokenString: String? = "") {
        self.firstName = firstNameString
        self.lastName = lastNameString
        self.fullName = fullNameString
        self.phoneNum = phoneNumString
        self.userID = userIDString
        self.timeJoined = timeJoinedNum
        self.pushToken = pushTokenString
    }
    
}
