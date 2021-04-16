//
//  EnterNameViewController.swift
//  Iris
//
//  Created by Shalin Shah on 1/5/20.
//  Copyright © 2020 Shalin Shah. All rights reserved.
//

import UIKit
import CoreData
import Mixpanel
import FirebaseAuth
import FirebaseFirestore

class EnterNameViewController: UIViewController {
    
    var keyboardPushedUp: Bool! = false
    
    @IBOutlet weak var nameLabel: UITextField! {
        didSet {
            let leftView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 15.0, height: 2.0))
            self.nameLabel.leftView = leftView
            self.nameLabel.leftViewMode = .always
            self.nameLabel.attributedPlaceholder = NSAttributedString(string: "Edwin", attributes: [NSAttributedString.Key.foregroundColor: UIColor.ColorTheme.Gray.MineShaft])
            self.nameLabel.font = UIFont(name: "NunitoSans-Regular", size: 21)
            self.nameLabel.isOpaque = true
            self.nameLabel.layer.addBorder(edge: UIRectEdge.left, color: UIColor.ColorTheme.Blue.Electric, thickness: 3.0)
            self.nameLabel.textContentType = .givenName
            self.nameLabel.keyboardType = .namePhonePad
            self.nameLabel.keyboardAppearance = .dark
            self.nameLabel.layer.shouldRasterize = true
            self.nameLabel.layer.rasterizationScale = UIScreen.main.scale
        }
    }
    
    @IBOutlet weak var continueButton: UIButton! {
        didSet {
            self.continueButton.roundCorners([.allCorners], radius: 5.0)
            self.continueButton.backgroundColor = UIColor.ColorTheme.Blue.Electric
            self.continueButton.titleLabel?.font = UIFont(name: "NunitoSans-Bold", size: 16)
            self.continueButton.layer.shouldRasterize = true
            self.continueButton.layer.rasterizationScale = UIScreen.main.scale
        }
    }
    
    @IBOutlet weak var errorIcon: UIImageView! {
        didSet {
            self.errorIcon.isHidden = true
            self.errorIcon.layer.shouldRasterize = true
            self.errorIcon.layer.rasterizationScale = UIScreen.main.scale
        }
    }

    @IBOutlet weak var errorLabel: UILabel! {
        didSet {
            self.errorLabel.isHidden = true
            self.errorLabel.font = UIFont(name: "NunitoSans-Regular", size: 16)
            self.errorLabel.layer.shouldRasterize = true
            self.errorLabel.layer.rasterizationScale = UIScreen.main.scale
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        let swipe: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        swipe.direction = .down
        view.addGestureRecognizer(swipe)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.view.layer.shouldRasterize = true
        self.view.layer.rasterizationScale = UIScreen.main.scale
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.delay(0.1) {self.nameLabel.becomeFirstResponder()}
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if (!keyboardPushedUp) {
                self.animateViewMoving(up: true, moveValue: keyboardSize.height)
            }
        }
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if (keyboardPushedUp) {
                self.animateViewMoving(up: false, moveValue: keyboardSize.height)
            }
        }
    }

    func animateViewMoving (up:Bool, moveValue :CGFloat) {
        if (keyboardPushedUp) {
            self.keyboardPushedUp = false
        } else {
            self.keyboardPushedUp = true
        }
        let movement:CGFloat = (up ? -moveValue : moveValue)
        UIView.animate(withDuration: 0.3
        , animations: {
            self.continueButton.frame = self.continueButton.frame.offsetBy(dx: 0, dy: movement)
        }, completion: nil)
    }
    
    
    // IB Actions
    
    @IBAction func continueTapped(_ sender: Any) {
        guard let text = nameLabel.text else {
            return
        }
        if text.count > 0 {
            // Write user to Firebase
            let (firstName, response) = self.checkNameString(name: text)
            if (response != "Okay") {
                DispatchQueue.main.async {
                    self.errorLabel.text = response
                    self.errorIcon.isHidden = false
                    self.errorLabel.isHidden = false
                }
//                self.showAlert(message: nil, title: response, completionHandler: {_ in })
            } else {
                let user = Auth.auth().currentUser!
                let animation = self.addAnimation()
                let userProfile = UserProfiles(firstNameString: firstName, lastNameString: "none", fullNameString: firstName, phoneNumString: user.phoneNumber, userIDString: user.uid, timeJoinedNum: Date().timeIntervalSince1970 as NSNumber, pushTokenString: "none")
                
                Mixpanel.mainInstance().people.set(properties: [ "First Name": firstName, "Phone Number": user.phoneNumber ?? "", "Date Joined":Date().timeIntervalSince1970, "UserID": user.uid, "Spotify Allowed": false])
                
                try? DataController.shared.createNewUser(fromUserProfile: userProfile)
                
                UserProfilesManager.writeNewUser(db: Firestore.firestore(), userProfiles: userProfile, success: { success in
                    if success {
                        self.removeAnimation(loader: animation)
                        self.dismissKeyboard()
//                        let next: EnterYearViewController? = self.storyboard?.instantiateViewController()
                        let next: InstallCardsViewController? = self.storyboard?.instantiateViewController()
                        self.show(next!, sender: self)
                    } else {
                        self.showAlert(message: nil, title: "User wasn't created!", completionHandler: {_ in })
                    }
                })
            }
        } else {
            return
        }
    }
    
    @IBAction func goBackPressed(_ sender: Any) {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}
