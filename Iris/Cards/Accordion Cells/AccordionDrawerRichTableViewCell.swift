//
//  AccordionDrawerRichTableViewCell.swift
//  Iris
//
//  Created by Shalin Shah on 2/1/20.
//  Copyright © 2020 Shalin Shah. All rights reserved.
//

import UIKit

class AccordionDrawerRichTableViewCell: UITableViewCell {
        
    @IBOutlet weak var detailTitle: UILabel! {
        didSet {
            self.detailTitle.layer.shouldRasterize = true
            self.detailTitle.layer.rasterizationScale = UIScreen.main.scale
        }
    }

    @IBOutlet weak var detailSmallLabelOne: UILabel! {
        didSet {
            self.detailSmallLabelOne.layer.shouldRasterize = true
            self.detailSmallLabelOne.layer.rasterizationScale = UIScreen.main.scale
        }
    }
    
    @IBOutlet weak var arrowIcon: UIImageView! {
        didSet {
            self.arrowIcon.layer.shouldRasterize = true
            self.arrowIcon.layer.rasterizationScale = UIScreen.main.scale
        }
    }
    
    @IBOutlet weak var detailSmallLabelTwo: UILabel! {
        didSet {
            self.detailSmallLabelTwo.layer.shouldRasterize = true
            self.detailSmallLabelTwo.layer.rasterizationScale = UIScreen.main.scale
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
}

