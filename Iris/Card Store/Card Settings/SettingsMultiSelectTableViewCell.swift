//
//  SettingsMultiSelectTableViewCell.swift
//  Iris
//
//  Created by Shalin Shah on 1/23/20.
//  Copyright © 2020 Shalin Shah. All rights reserved.
//

import UIKit

class SettingsMultiSelectTableViewCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel! {
        didSet {
            self.title.layer.shouldRasterize = true
            self.title.layer.rasterizationScale = UIScreen.main.scale
        }
    }
    
    @IBOutlet weak var checkBox: UIImageView! {
           didSet {
               self.checkBox.layer.shouldRasterize = true
               self.checkBox.layer.rasterizationScale = UIScreen.main.scale
           }
       }

    override func awakeFromNib() {
        super.awakeFromNib()
    
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
}
