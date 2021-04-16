//
//  FirstScreenViewController.swift
//  Iris
//
//  Created by Shalin Shah on 2/4/20.
//  Copyright © 2020 Shalin Shah. All rights reserved.
//

import UIKit

class FirstScreenViewController: UIViewController {
    
    @IBOutlet weak var roundedView: UIView! {
        didSet {
            self.roundedView.addTopRoundedEdge(desiredCurve: 1.0)
            self.roundedView.layer.backgroundColor = UIColor.ColorTheme.Blue.Mirage.cgColor

            self.roundedView.layer.shouldRasterize = true
            self.roundedView.layer.rasterizationScale = UIScreen.main.scale
        }
    }
    
    @IBOutlet weak var borderRoundedView: UIView! {
        didSet {
            self.borderRoundedView.addTopRoundedEdge(desiredCurve: 1.0)

            self.borderRoundedView.layer.shouldRasterize = true
            self.borderRoundedView.layer.rasterizationScale = UIScreen.main.scale
        }
    }

    
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            self.titleLabel.layer.shouldRasterize = true
            self.titleLabel.layer.rasterizationScale = UIScreen.main.scale
        }
    }
    
    @IBOutlet weak var phoneTextField: UITextField! {
        didSet {
            self.phoneTextField.delegate = self
            
            let prefix = UILabel(frame: CGRect(x: 10.0, y: -1.5, width: 50.0, height: 36.0))
            prefix.text = "  +1  "
            prefix.font = UIFont(name: "NunitoSans-SemiBold", size: 21)
            prefix.textColor = .white
            self.phoneTextField.leftView = prefix
            self.phoneTextField.leftViewMode = .always
            self.phoneTextField.attributedPlaceholder = NSAttributedString(string: "678 136 7092", attributes: [NSAttributedString.Key.foregroundColor: UIColor.ColorTheme.Gray.MineShaft])
            self.phoneTextField.font = UIFont(name: "NunitoSans-Regular", size: 21)
            self.phoneTextField.isOpaque = true
            self.phoneTextField.layer.addBorder(edge: UIRectEdge.left, color: UIColor.ColorTheme.Blue.Electric, thickness: 3.0)
            self.phoneTextField.layer.shouldRasterize = true
            self.phoneTextField.layer.rasterizationScale = UIScreen.main.scale
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

}

extension FirstScreenViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        DispatchQueue.main.async {
            self.dismissKeyboard()
            let next: EnterNumberViewController? = self.storyboard?.instantiateViewController()
            self.show(next!, sender: self)
        }
    }
}
