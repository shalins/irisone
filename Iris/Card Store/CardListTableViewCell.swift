//
//  CardListTableViewCell.swift
//  Iris
//
//  Created by Shalin Shah on 1/15/20.
//  Copyright © 2020 Shalin Shah. All rights reserved.
//

import UIKit
import FirebaseAuth

class CardInstallTableViewCell: UITableViewCell {
        
    @IBOutlet weak var icon: UIImageView! {
        didSet {
            self.icon.layer.shouldRasterize = true
            self.icon.layer.rasterizationScale = UIScreen.main.scale
        }
    }
    
    @IBOutlet weak var title: UILabel! {
        didSet {
            self.title.layer.shouldRasterize = true
            self.title.layer.rasterizationScale = UIScreen.main.scale
        }
    }
    
    @IBOutlet weak var subLabel: UILabel! {
        didSet {
            self.subLabel.layer.shouldRasterize = true
            self.subLabel.layer.rasterizationScale = UIScreen.main.scale
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


