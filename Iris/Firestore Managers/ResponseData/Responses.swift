//
//  Responses.swift
//  Iris
//
//  Created by Shalin Shah on 1/16/20.
//  Copyright © 2020 Shalin Shah. All rights reserved.
//

import Foundation

class Responses {
    var responseID: String?
    var sentenceFormat: [String]?
    var sentence: [String]?
    var alerts: [String]?
    var responseURL: String?
    var responseURLType: String?

    init(responseIDString: String? = "", alertsArray: [String]? = ["none"], sentenceFormatArray: [String]? = ["none"], sentenceArray: [String]? = ["none"], responseURLString: String? = "", responseURLTypeString: String? = "") {
        self.responseID = responseIDString
        self.alerts = alertsArray
        self.sentence = sentenceArray
        self.sentenceFormat = sentenceFormatArray
        self.responseURL = responseURLString
        self.responseURLType = responseURLTypeString
    }
}
