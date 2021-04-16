//
//  AccordionItemsRefreshTableViewCell.swift
//  Iris
//
//  Created by Shalin Shah on 2/1/20.
//  Copyright © 2020 Shalin Shah. All rights reserved.
//

import UIKit

class AccordionItemsRefreshTableViewCell: UITableViewCell {
    
    @IBOutlet weak var detailTitle: UILabel! {
        didSet {
            self.detailTitle.layer.shouldRasterize = true
            self.detailTitle.layer.rasterizationScale = UIScreen.main.scale
        }
    }
    
    @IBOutlet weak var detailImage: UIImageView! {
        didSet {
            self.detailImage.makeCorner(withRadius: self.detailImage.frame.height/2)
            self.detailImage.contentMode = .scaleAspectFill
            self.detailImage.layer.shouldRasterize = true
            self.detailImage.layer.rasterizationScale = UIScreen.main.scale
        }
    }

    @IBOutlet weak var detailSmallLabelOne: UILabel! {
        didSet {
            self.detailSmallLabelOne.layer.shouldRasterize = true
            self.detailSmallLabelOne.layer.rasterizationScale = UIScreen.main.scale
        }
    }
        
    @IBOutlet weak var detailSmallLabelTwo: UILabel! {
        didSet {
            self.detailSmallLabelTwo.layer.shouldRasterize = true
            self.detailSmallLabelTwo.layer.rasterizationScale = UIScreen.main.scale
        }
    }
    
    @IBOutlet weak var refreshButton: ButtonWithRowAndSection! {
        didSet {
            self.refreshButton.layer.shouldRasterize = true
            self.refreshButton.layer.rasterizationScale = UIScreen.main.scale
        }
    }

    @IBOutlet weak var bgView: UIView! {
        didSet {
            self.bgView.makeCorner(withRadius: 8)
            self.bgView.layer.shouldRasterize = true
            self.bgView.layer.rasterizationScale = UIScreen.main.scale
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

