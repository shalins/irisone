//
//  EnterYearViewController.swift
//  Iris
//
//  Created by Shalin Shah on 2/29/20.
//  Copyright © 2020 Shalin Shah. All rights reserved.
//

import Foundation

import UIKit
import CoreData
import FirebaseAuth
import FirebaseFirestore
import Mixpanel

class EnterYearViewController: UIViewController {
            
    @IBOutlet weak var freshmanButton: UIButton! {
        didSet {
            self.freshmanButton.roundCorners([.allCorners], radius: 5.0)
            self.freshmanButton.backgroundColor = UIColor.ColorTheme.Blue.Mirage
            self.freshmanButton.titleLabel?.font = UIFont(name: "NunitoSans-Bold", size: 16)
            self.freshmanButton.layer.shouldRasterize = true
            self.freshmanButton.layer.rasterizationScale = UIScreen.main.scale
        }
    }
    
    @IBOutlet weak var sophomoreButton: UIButton! {
        didSet {
            self.sophomoreButton.roundCorners([.allCorners], radius: 5.0)
            self.sophomoreButton.backgroundColor = UIColor.ColorTheme.Blue.Mirage
            self.sophomoreButton.titleLabel?.font = UIFont(name: "NunitoSans-Bold", size: 16)
            self.sophomoreButton.layer.shouldRasterize = true
            self.sophomoreButton.layer.rasterizationScale = UIScreen.main.scale
        }
    }

    
    @IBOutlet weak var juniorButton: UIButton! {
        didSet {
            self.juniorButton.roundCorners([.allCorners], radius: 5.0)
            self.juniorButton.backgroundColor = UIColor.ColorTheme.Blue.Mirage
            self.juniorButton.titleLabel?.font = UIFont(name: "NunitoSans-Bold", size: 16)
            self.juniorButton.layer.shouldRasterize = true
            self.juniorButton.layer.rasterizationScale = UIScreen.main.scale
        }
    }

    
    @IBOutlet weak var seniorButton: UIButton! {
        didSet {
            self.seniorButton.roundCorners([.allCorners], radius: 5.0)
            self.seniorButton.backgroundColor = UIColor.ColorTheme.Blue.Mirage
            self.seniorButton.titleLabel?.font = UIFont(name: "NunitoSans-Bold", size: 16)
            self.seniorButton.layer.shouldRasterize = true
            self.seniorButton.layer.rasterizationScale = UIScreen.main.scale
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.layer.shouldRasterize = true
        self.view.layer.rasterizationScale = UIScreen.main.scale
    }
    
    func installCardCollection(animation: LoadingHUD, upperClassman: Bool) {
        let cardIds = upperClassman ? ["0a978550-da18-4130-9889-6d3a5f7e4876", "fe7b6ee6-e128-455e-8818-47a947a42daf", "ce76d1e4-5d8e-4ad9-be2d-38a3b39a8ad4"]: ["9cdc879d-4af7-4a44-8869-738efd602063", "fe7b6ee6-e128-455e-8818-47a947a42daf", "54084c29-c420-43ac-8947-e3b92a2be7d8"]
        UserProfilesManager.fetchGlobalCards(db: Firestore.firestore(), response: { response in
            if response?.first?.cardName != "" {
                self.installAllCards(cards: response ?? [GlobalCards](), animation: animation, cardIDs: cardIds)
            } else {
                self.showAlert(message: nil, title: "Error fetching cards!", completionHandler: {_ in })
            }
        })
    }
    
    func installAllCards(cards: [GlobalCards], animation: LoadingHUD, cardIDs: [String]) {
        let myGroup = DispatchGroup()

        for card in cards {
            myGroup.enter()
            if (cardIDs.contains(card.cardID ?? "")) {
                Mixpanel.mainInstance().track(event: "Added Card")
                Mixpanel.mainInstance().people.increment(property: "Card Count", by: 1)
                DataController.shared.installCard(forUserWithID: Auth.auth().currentUser!.uid, fromGlobalCard: card, orderNumber: Int(truncating: card.order ?? 0), newCard: { card in
                })
            }
            myGroup.leave()
        }
        
        myGroup.notify(queue: .main) {
            DispatchQueue.main.async {
                self.removeAnimation(loader: animation)
                let next: InstallCardsViewController? = self.storyboard?.instantiateViewController()
                self.show(next!, sender: self)
            }
        }
    }

    
    // IB Actions
    @IBAction func freshmanTapped(_ sender: Any) {
        let animation = self.addAnimation()
        self.installCardCollection(animation: animation, upperClassman: false)
    }
    
    @IBAction func sophomoreTapped(_ sender: Any) {
        let animation = self.addAnimation()
        self.installCardCollection(animation: animation, upperClassman: false)
    }
    
    @IBAction func juniorTapped(_ sender: Any) {
        let animation = self.addAnimation()
        self.installCardCollection(animation: animation, upperClassman: true)
    }

    @IBAction func seniorTapped(_ sender: Any) {
        let animation = self.addAnimation()
        self.installCardCollection(animation: animation, upperClassman: true)
    }
    
}
