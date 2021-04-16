//
//  Subdetails.swift
//  Iris
//
//  Created by Shalin Shah on 1/16/20.
//  Copyright © 2020 Shalin Shah. All rights reserved.
//

import Foundation

class Subdetails {
    var subdetailID: String?
    var timestamp: Double?
    var richLabel: [String: String]?
    var richSublabel: [String: String]?
    var richDescription: [String: String]?
    var richSmallLabelOne: [String: String]?
    var richSmallLabelTwo: [String: String]?
    var richMetric: [String: String]?
    var richMetricUnits: [String: String]?
    var richMetricTwo: [String: String]?
    var richMetricUnitsTwo: [String: String]?
    var order: Double?

    init(timestampNum: Double? = 0, richLabelArray: [String: String]? = ["none": "none"],  richSublabelArray: [String: String]? = ["none": "none"],  richDescriptionArray: [String: String]? = ["none": "none"],  richSmallLabelOneArray: [String: String]? = ["none": "none"],  richSmallLabelTwoArray: [String: String]? = ["none": "none"],  richMetricArray: [String: String]? = ["none": "none"],  richMetricUnitsArray: [String: String]? = ["none": "none"], richMetricTwoArray: [String: String]? = ["none": "none"],  richMetricUnitsTwoArray: [String: String]? = ["none": "none"], subdetailIDString: String? = "", orderNum: Double? = 0) {
        self.timestamp = timestampNum
        self.richLabel = richLabelArray
        self.richSublabel = richSublabelArray
        self.richDescription = richDescriptionArray
        self.richSmallLabelOne = richSmallLabelOneArray
        self.richSmallLabelTwo = richSmallLabelTwoArray
        self.richMetric = richMetricArray
        self.richMetricUnits = richMetricUnitsArray
        self.richMetricTwo = richMetricTwoArray
        self.richMetricUnitsTwo = richMetricUnitsTwoArray
        self.subdetailID = subdetailIDString
        self.order = orderNum
    }
}
