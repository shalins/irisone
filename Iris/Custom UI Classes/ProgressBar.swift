//
//  ProgressBar.swift
//  Iris
//
//  Created by Shalin Shah on 1/22/20.
//  Copyright © 2020 Shalin Shah. All rights reserved.
//

import UIKit

@IBDesignable
class ProgressBar: UIView {


    //====================================
    //MARK: Properties
    //====================================
    private var progressBackgroundView : UIView?
    private var progressBarView : UIView?
    
    private var progressBarViewWidthConstraint : NSLayoutConstraint?
    
    //Colors
    @IBInspectable var progressBackgroundColor : UIColor = UIColor(white: 1.0, alpha: 0.5){
        didSet{
            self.progressBackgroundView?.backgroundColor = progressBackgroundColor
        }
    }
    @IBInspectable var progressBarColor : UIColor = .white{
        didSet{
            self.progressBarView?.backgroundColor = progressBarColor
        }
    }

    //Paddings
    @IBInspectable var verticalPadding : CGFloat = 8.0
    @IBInspectable var horizontalPadding : CGFloat = 8.0
    
    //Paddings
    @IBInspectable var progressPercent: CGFloat = 50.0
    
    //Direction
    @IBInspectable var isRTL: Bool = false
    
    //====================================
    //MARK: ============== Implementation ==============
    //====================================
    override func draw(_ rect: CGRect) {

        self.progressBackgroundView = self.makeProgressBarView(withColor: self.progressBackgroundColor, isGradient: false)
        self.addSubview(self.progressBackgroundView!)
        self.progressBarView = self.makeProgressBarView(withColor: self.progressBarColor, isGradient: true)
        self.addSubview(self.progressBarView!)
        
        self.setConstraints()
    }
    
    
    //====================================
    //MARK: Make views
    //====================================
    private func makeProgressBarView(withColor color: UIColor, isGradient: Bool) -> UIView{
        
        //Get frame
        let progressViewWidth = self.frame.size.width - (self.horizontalPadding * 2)
        let progressViewHeight = self.frame.size.height - (self.verticalPadding * 2)
        
        //Make view
        let progressView = UIView(frame: CGRect(x: 0, y: 0, width: progressViewWidth, height: progressViewHeight))
        progressView.layer.masksToBounds = true
        progressView.layer.cornerRadius = progressViewHeight/2
        
        
        //Set color
        if (isGradient) {
            let gradientLayer = CAGradientLayer()
            gradientLayer.colors = [UIColor(displayP3Red: 249.0/255.0, green: 59.0/255.0, blue: 118.0/255.0, alpha: 1.0).cgColor, UIColor(displayP3Red: 188.0/255.0, green: 63.0/255.0, blue: 188.0/255.0, alpha: 1.0).cgColor]
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
            gradientLayer.locations = [0, 1]
            gradientLayer.frame = bounds
            progressView.layer.insertSublayer(gradientLayer, at: 0)
        } else {
            progressView.backgroundColor = color
        }
        
        
        //Return
        return progressView
    }
    
    

    //====================================
    //MARK: Set constraints
    //====================================
    private func setConstraints(){
        
        
        //Background constraints
        self.progressBackgroundView!.translatesAutoresizingMaskIntoConstraints = false
        var topSpaceConstraint = NSLayoutConstraint(item: self.progressBackgroundView!,
                                                    attribute: .top, relatedBy: .equal,
                                                    toItem: self, attribute: .top,
                                                    multiplier: 1,
                                                    constant: self.verticalPadding)
        
        var bottomSpaceConstraint = NSLayoutConstraint(item: self.progressBackgroundView!,
                                                       attribute: .bottom,
                                                       relatedBy: .equal,
                                                       toItem: self, attribute: .bottom,
                                                       multiplier: 1,
                                                       constant: -self.verticalPadding)
        
        let leadingSpaceConstraint = NSLayoutConstraint(item: self.progressBackgroundView!,
                                                        attribute: .leading,
                                                        relatedBy: .equal,
                                                        toItem: self,
                                                        attribute: .leading,
                                                        multiplier: 1,
                                                        constant: self.horizontalPadding)
        
        let trailingSpaceConstraint = NSLayoutConstraint(item: self.progressBackgroundView!,
                                                         attribute: .trailing,
                                                         relatedBy: .equal,
                                                         toItem: self,
                                                         attribute: .trailing,
                                                         multiplier: 1,
                                                         constant: -self.horizontalPadding)
        
        self.addConstraints([topSpaceConstraint,
                             bottomSpaceConstraint,
                             leadingSpaceConstraint,
                             trailingSpaceConstraint])
        
        
        
        
        //Progress constraints
        self.progressBarView!.translatesAutoresizingMaskIntoConstraints = false
        topSpaceConstraint = NSLayoutConstraint(item: self.progressBarView!,
                                                attribute: .top,
                                                relatedBy: .equal,
                                                toItem: self,
                                                attribute: .top,
                                                multiplier: 1,
                                                constant: self.verticalPadding)
        
        bottomSpaceConstraint = NSLayoutConstraint(item: self.progressBarView!,
                                                   attribute: .bottom,
                                                   relatedBy: .equal,
                                                   toItem: self,
                                                   attribute: .bottom,
                                                   multiplier: 1,
                                                   constant: -self.verticalPadding)
        
        
        let leadingStickConstraint : NSLayoutConstraint //Stick to the trailing if RTL
        if self.isRTL{
            leadingStickConstraint = NSLayoutConstraint(item: self.progressBarView!,
                                                        attribute: .trailing,
                                                        relatedBy: .equal,
                                                        toItem: self.progressBackgroundView,
                                                        attribute: .trailing,
                                                        multiplier: 1,
                                                        constant: 0.0)
        }else{
            leadingStickConstraint = NSLayoutConstraint(item: self.progressBarView!,
                                                        attribute: .leading,
                                                        relatedBy: .equal,
                                                        toItem: self.progressBackgroundView,
                                                        attribute: .leading,
                                                        multiplier: 1,
                                                        constant: 0.0)
        }
        
        
        let progressWidth = self.progressBackgroundView!.frame.size.width * (self.progressPercent / 100.0)
        self.progressBarViewWidthConstraint = NSLayoutConstraint(item: self.progressBarView!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: progressWidth)
        
        self.addConstraints([topSpaceConstraint,bottomSpaceConstraint,leadingStickConstraint,self.progressBarViewWidthConstraint!])
    }
    
    
    //====================================
    //MARK: Set progress
    //====================================
    func setProgress(percent:CGFloat){
        self.progressPercent = percent * 100
        self.progressBarViewWidthConstraint?.constant = self.progressBackgroundView!.frame.size.width * percent
        self.layoutIfNeeded()
    }
    

}
