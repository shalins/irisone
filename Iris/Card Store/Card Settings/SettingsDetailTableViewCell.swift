//
//  SettingsDetailTableViewCell.swift
//  Iris
//
//  Created by Shalin Shah on 1/17/20.
//  Copyright © 2020 Shalin Shah. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class SettingsDetailTableViewCell: UITableViewCell {

    var coordinate: CLLocationCoordinate2D?
    
    @IBOutlet weak var title: UILabel! {
        didSet {
            self.title.layer.shouldRasterize = true
            self.title.layer.rasterizationScale = UIScreen.main.scale
        }
    }
    
    @IBOutlet weak var subTitle: UILabel! {
        didSet {
            self.subTitle.layer.shouldRasterize = true
            self.subTitle.layer.rasterizationScale = UIScreen.main.scale
        }
    }


    override func awakeFromNib() {
        super.awakeFromNib()
    
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
}
