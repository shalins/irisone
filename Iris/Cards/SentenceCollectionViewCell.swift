//
//  SentenceCollectionViewCell.swift
//  Iris
//
//  Created by Shalin Shah on 1/16/20.
//  Copyright © 2020 Shalin Shah. All rights reserved.
//

import UIKit

class NormalSentenceCollectionViewCell: UICollectionViewCell {
            
    @IBOutlet weak var word: UILabel! {
        didSet {
            self.word.font = UIFont(name: "NunitoSans-SemiBold", size: 28)
            self.word.layer.shouldRasterize = true
            self.word.layer.rasterizationScale = UIScreen.main.scale
        }
    }
    
    
    public override func prepareForReuse() {
        self.word.text = nil
        self.word.textColor = .white
        super.prepareForReuse()
    }


    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
}

class GradientSentenceCollectionView: UICollectionViewCell {
    
    @IBOutlet weak var word: UILabel! {
        didSet {
            self.word.font = UIFont(name: "NunitoSans-SemiBold", size: 28)
            self.word.layer.shouldRasterize = true
            self.word.layer.rasterizationScale = UIScreen.main.scale
        }
    }
    
    @IBOutlet weak var edit: UIImageView! {
        didSet {
            self.edit.layer.shouldRasterize = true
            self.edit.layer.rasterizationScale = UIScreen.main.scale
        }
    }

    
    @IBOutlet weak var bgView: UIView! {
        didSet {
            self.bgView.layer.shouldRasterize = true
            self.bgView.layer.rasterizationScale = UIScreen.main.scale
        }
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
    }


    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
}



extension UIImage{
    convenience init(view: UIView) {

        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: (image?.cgImage)!)

    }
}

@IBDesignable
class GradientView: UIView {

    private var gradientLayer = CAGradientLayer()
    private var vertical: Bool = false

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        // Drawing code

        //fill view with gradient layer
        gradientLayer.frame = self.bounds

        //style and insert layer if not already inserted
        if gradientLayer.superlayer == nil {

            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = vertical ? CGPoint(x: 0, y: 1) : CGPoint(x: 1, y: 0)
            gradientLayer.colors = [UIColor(displayP3Red: 249.0/255.0, green: 59.0/255.0, blue: 118.0/255.0, alpha: 1.0).cgColor, UIColor(displayP3Red: 188.0/255.0, green: 63.0/255.0, blue: 188.0/255.0, alpha: 1.0).cgColor]

            gradientLayer.locations = [0.0, 1.0]

            self.layer.insertSublayer(gradientLayer, at: 0)
        }
    }

}
