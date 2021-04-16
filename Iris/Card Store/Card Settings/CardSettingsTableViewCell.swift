
//
//  CardSettingsTableViewCell.swift
//  Iris
//
//  Created by Shalin Shah on 1/17/20.
//  Copyright © 2020 Shalin Shah. All rights reserved.
//

import Foundation
import UIKit

class CardSettingsTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel! {
        didSet {
            self.title.layer.shouldRasterize = true
            self.title.layer.rasterizationScale = UIScreen.main.scale
        }
    }
    
    @IBOutlet weak var editButton: UIButton! {
        didSet {
            self.editButton.layer.shouldRasterize = true
            self.editButton.layer.rasterizationScale = UIScreen.main.scale
        }
    }
    
    @IBOutlet weak var deleteButton: UIButton! {
        didSet {
            self.deleteButton.layer.shouldRasterize = true
            self.deleteButton.layer.rasterizationScale = UIScreen.main.scale
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
}
