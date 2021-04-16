//
//  Details.swift
//  Iris
//
//  Created by Shalin Shah on 1/16/20.
//  Copyright © 2020 Shalin Shah. All rights reserved.
//

import Foundation

class Details {
    var detailID: String?
    var richLabel: [String: String]?
    var richSmallLabelOne: [String: String]?
    var richSmallLabelTwo: [String: String]?
    var lat: Double?
    var lon: Double?
    var order: Double?

    init(detailIDString: String? = "", richLabelString: [String: String]? = ["none": "none"], richSmallLabelOneString: [String: String]? = ["none": "none"], richSmallLabelTwoString: [String: String]? = ["none": "none"], latNum: Double? = 0, lonNum: Double? = 0, orderNum: Double? = 0) {
        self.detailID = detailIDString
        self.richLabel = richLabelString
        self.richSmallLabelOne = richSmallLabelOneString
        self.richSmallLabelTwo = richSmallLabelTwoString
        self.lat = latNum
        self.lon = lonNum
        self.order = orderNum
    }
}
