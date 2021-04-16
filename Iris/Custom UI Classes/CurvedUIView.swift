//
//  CurvedUIView.swift
//  Iris
//
//  Created by Shalin Shah on 1/18/20.
//  Copyright © 2020 Shalin Shah. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class CurvedUIView: UIView {

    private func pathCurvedForView(givenView: UIView, curvedPercent:CGFloat) ->UIBezierPath
    {
        let arrowPath = UIBezierPath()
        arrowPath.move(to: CGPoint(x:0, y:0))
        arrowPath.addLine(to: CGPoint(x:givenView.bounds.size.width, y:0))
        arrowPath.addLine(to: CGPoint(x:givenView.bounds.size.width, y:givenView.bounds.size.height))
        arrowPath.addQuadCurve(to: CGPoint(x:0, y:givenView.bounds.size.height), controlPoint: CGPoint(x:givenView.bounds.size.width/2, y:givenView.bounds.size.height-givenView.bounds.size.height*curvedPercent))
        arrowPath.addLine(to: CGPoint(x:0, y:0))
        arrowPath.close()

        return arrowPath
    }

    @IBInspectable var curvedPercent : CGFloat = 0{
        didSet{
            guard curvedPercent <= 1 && curvedPercent >= 0 else{
                return
            }

            let shapeLayer = CAShapeLayer(layer: self.layer)
            shapeLayer.path = self.pathCurvedForView(givenView: self,curvedPercent: curvedPercent).cgPath
            shapeLayer.frame = self.bounds
            shapeLayer.masksToBounds = true
            self.layer.mask = shapeLayer
        }
    }
    
    func rotate(angle: CGFloat) {
        let radians = angle / 180.0 * CGFloat.pi
        let rotation = self.transform.rotated(by: radians)
        self.transform = rotation
    }
}

