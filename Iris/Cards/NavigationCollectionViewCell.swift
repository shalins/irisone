//
//  NavigationCollectionViewCell.swift
//  Iris
//
//  Created by Shalin Shah on 1/8/20.
//  Copyright © 2020 Shalin Shah. All rights reserved.
//

import UIKit

class NavigationCollectionViewCell: UICollectionViewCell {
        
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    
        
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
}

