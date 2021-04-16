//
//  DetailTableViewCell.swift
//  Iris
//
//  Created by Shalin Shah on 1/22/20.
//  Copyright © 2020 Shalin Shah. All rights reserved.
//

import UIKit

class DetailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var progressView: ProgressBar! {
        didSet {
            self.progressView.progressBackgroundColor = UIColor.ColorTheme.Blue.Mirage
            self.progressView.layer.shouldRasterize = true
            self.progressView.layer.rasterizationScale = UIScreen.main.scale
        }
    }
    
    @IBOutlet weak var percentage: UILabel! {
        didSet {
            self.percentage.layer.shouldRasterize = true
            self.percentage.layer.rasterizationScale = UIScreen.main.scale
        }
    }

    
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
    
    @IBOutlet weak var detailSmallLabelTwo: UILabel! {
        didSet {
            self.detailSmallLabelTwo.layer.shouldRasterize = true
            self.detailSmallLabelTwo.layer.rasterizationScale = UIScreen.main.scale
        }
    }
    
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
        progressView.setProgress(percent: 0.0)
//        progressView.subviews.forEach({ $0.removeFromSuperview() })
        super.prepareForReuse()
    }


    override func awakeFromNib() {
        super.awakeFromNib()

        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }


}
