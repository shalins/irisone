//
//  ChoicesCollectionViewCell.swift
//  Iris
//
//  Created by Shalin Shah on 1/9/20.
//  Copyright © 2020 Shalin Shah. All rights reserved.
//

import Foundation
import UIKit

class ChoicesCollectionViewCell: UICollectionViewCell {
            
    @IBOutlet weak var title: UILabel! {
        didSet {
            self.title.layer.shouldRasterize = true
            self.title.layer.rasterizationScale = UIScreen.main.scale
        }
    }

    
    func getFirstLetter(from: String) -> String {
        return from.first?.uppercased() ?? ""
    }


    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = 5.0
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
}

