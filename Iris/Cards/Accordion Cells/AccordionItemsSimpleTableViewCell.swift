//
//  AccordionItemsSimpleTableViewCell.swift
//  Iris
//
//  Created by Shalin Shah on 2/1/20.
//  Copyright © 2020 Shalin Shah. All rights reserved.
//

import UIKit

class AccordionItemsSimpleTableViewCell: UITableViewCell {
    
    @IBOutlet weak var detailDescription: UILabel! {
        didSet {
            self.detailDescription.layer.shouldRasterize = true
            self.detailDescription.layer.rasterizationScale = UIScreen.main.scale
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
        self.detailDescription.text = nil
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
}
