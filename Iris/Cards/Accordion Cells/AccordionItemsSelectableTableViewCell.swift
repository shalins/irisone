//
//  AccordionItemsSelectableTableViewCell.swift
//  Iris
//
//  Created by Shalin Shah on 2/1/20.
//  Copyright © 2020 Shalin Shah. All rights reserved.
//

import UIKit

class AccordionItemsSelectableTableViewCell: UITableViewCell {

    @IBOutlet weak var checkBox: UIImageView! {
        didSet {
                self.checkBox.layer.shouldRasterize = true
                self.checkBox.layer.rasterizationScale = UIScreen.main.scale
        }
    }

    @IBOutlet weak var detailTitle: UILabel! {
        didSet {
            self.detailTitle.layer.shouldRasterize = true
            self.detailTitle.layer.rasterizationScale = UIScreen.main.scale
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
