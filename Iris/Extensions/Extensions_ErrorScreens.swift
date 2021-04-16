//
//  Extensions_ErrorScreens.swift
//  Iris
//
//  Created by Shalin Shah on 2/9/20.
//  Copyright © 2020 Shalin Shah. All rights reserved.
//

import Foundation
import UIKit

enum ErrorType {
    case interalServer
    case noInternet
    case noContent
}


// this is for showing the error screens on the view controller
extension UICollectionViewCell {
    
    func addNetworkError(vc: UICollectionViewCell, type: ErrorType) -> ErrorView {
        let newLoader = ErrorView.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: self.frame.height))
        newLoader.delegate = vc as? ErrorViewDelegate
        
        if (type == .noInternet) {
            newLoader.title.text = "No internet!"
            newLoader.image.image = #imageLiteral(resourceName: "sad")
            newLoader.sentence.text = "The network is having a little trouble loading. Check your network and try again."
        } else if (type == .interalServer) {
            newLoader.title.text = "Oops, we did it again!"
            newLoader.image.image = #imageLiteral(resourceName: "sad")
            newLoader.sentence.text = "Ok, we did not expect this. An error occurred, and we’re working on solving this now."
        } else {
            newLoader.title.text = "No content near you!"
            newLoader.image.image = #imageLiteral(resourceName: "no_content")
            newLoader.sentence.text = "Try changing locations to display results."
            newLoader.refreshButton.isHidden = true
        }
        
        DispatchQueue.main.async {
            UIView.transition(with: self, duration: 0.1, options: .transitionCrossDissolve, animations: {
                self.addSubview(newLoader)
            })
        }
        return newLoader
    }
    
    func removeNetworkError(error: ErrorView?) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
            UIView.transition(with: self, duration: 0.1, options: .transitionCrossDissolve, animations: {
                if (error != nil) {
                    error!.removeFromSuperview()
                }
            })
        }
    }
}
