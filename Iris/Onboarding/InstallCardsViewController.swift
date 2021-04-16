//
//  InstallCardsViewController.swift
//  Iris
//
//  Created by Shalin Shah on 1/30/20.
//  Copyright © 2020 Shalin Shah. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import Alamofire
import CoreLocation
import Mixpanel

class InstallCardsViewController: UIViewController {
    
    var cardCollection: [GlobalCards]? = [GlobalCards]()
    var localCardCollection: [Card]? = [Card]()
    var installed: [String]? = [String]()
    var user: User?

    @IBOutlet weak var cardListTableView: UITableView! {
        didSet {
            self.cardListTableView.delegate = self
            self.cardListTableView.dataSource = self
            self.cardListTableView.layer.shouldRasterize = true
            self.cardListTableView.layer.rasterizationScale = UIScreen.main.scale
        }
    }
    
    @IBOutlet weak var doneButtonBackgroundView: UIView! {
        didSet {
            self.doneButtonBackgroundView.isHidden = true
            self.doneButtonBackgroundView.layer.shouldRasterize = true
            self.doneButtonBackgroundView.layer.rasterizationScale = UIScreen.main.scale
        }
    }
    
    @IBOutlet weak var doneButton: UIButton! {
        didSet {
            self.doneButton.makeCorner(withRadius: 8)
            self.doneButton.backgroundColor = UIColor.ColorTheme.Blue.Electric
            self.doneButton.layer.shouldRasterize = true
            self.doneButton.layer.rasterizationScale = UIScreen.main.scale
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.getCardCollection()
        
        self.view.layer.shouldRasterize = true
        self.view.layer.rasterizationScale = UIScreen.main.scale
    }
        
    func getCardCollection() {
        UserProfilesManager.fetchGlobalCards(db: Firestore.firestore(), response: { response in
            if response?.first?.cardName != "" {
                self.getInstalledCards()
                self.cardCollection = response ?? [GlobalCards]()
                let names = self.localCardCollection?.map { $0.globalCardID }
                self.installed = names as? [String]

                DispatchQueue.main.async {
                    if (self.localCardCollection!.count != 0 && self.doneButtonBackgroundView.isHidden) {
                        self.doneButtonLogic(shouldHide: false)
                    }
                    self.cardListTableView.reloadData()
                }
            } else {
                self.showAlert(message: nil, title: "Error fetching cards!", completionHandler: {_ in })
            }
        })
    }

    func getInstalledCards() {
        self.user = try? DataController.shared.getUser(fromID: Auth.auth().currentUser!.uid)
        
        let cards = try? DataController.shared.getCards(fromUser: self.user ?? User(context: DataController.shared.context))
        if cards?.count ?? 0 > 0 {
            self.localCardCollection = cards!
        }
    }
    
    func doneButtonLogic(shouldHide: Bool) {
        DispatchQueue.main.async {
            self.doneButtonBackgroundView.alpha = shouldHide ? 1.0 : 0.0 //for zero opacity
            self.doneButtonBackgroundView.isHidden = shouldHide
            let frameDelta = shouldHide ? self.doneButtonBackgroundView.frame.height: -self.doneButtonBackgroundView.frame.height
            self.cardListTableView.frame = CGRect(x: self.cardListTableView.frame.minX, y: self.cardListTableView.frame.minY, width: self.cardListTableView.frame.width, height: self.cardListTableView.frame.height + frameDelta)
            UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut, animations: {
                self.doneButtonBackgroundView.alpha = shouldHide ? 0.0 : 1.0 //for 100% opacity
            }, completion: nil)
        }
    }

    @IBAction func goToHome() {
        DispatchQueue.main.async {            
            let status = CLLocationManager.authorizationStatus()
            if (status == .notDetermined) {
                let next: LocationPermissionViewController? = self.storyboard?.instantiateViewController()
                self.show(next!, sender: self)
            } else {
                let next: HomeViewController? = self.storyboard?.instantiateViewController()
                self.show(next!, sender: self)
            }
        }
    }
}

extension InstallCardsViewController: UITableViewDelegate, UITableViewDataSource {
        
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cardCollection?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.cardListTableView.dequeueReusableCell(withIdentifier: "CardInstallTableViewCell", for: indexPath as IndexPath) as! CardInstallTableViewCell
                
        cell.title.text = self.cardCollection?[indexPath.row].cardName
        cell.icon.image = UIImage.getImage(self.cardCollection?[indexPath.row].icon ?? "none", sideLength: 30.0, color: .white)
        cell.subLabel.frame = CGRect(x: cell.subLabel.frame.minX, y: cell.subLabel.frame.minY, width: 225, height: cell.subLabel.frame.height)
        
        if (self.installed?.contains(self.cardCollection?[indexPath.row].cardID ?? "") ?? false) {
            cell.checkBox.image = #imageLiteral(resourceName: "checkbox_selected")
        } else {
            cell.checkBox.image = #imageLiteral(resourceName: "checkbox")
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.cardCollection?.count == 0 { return }

        guard let currentCard = self.cardCollection?[indexPath.row] else { return }
        guard let cell = self.cardListTableView.cellForRow(at: IndexPath(row: indexPath.row, section: 0)) as? CardInstallTableViewCell else { return }

        if (!(self.installed?.contains(self.cardCollection?[indexPath.row].cardID ?? "") ?? true)) {
            //
            // install the card from here
            //
            Mixpanel.mainInstance().track(event: "Added Card")
            Mixpanel.mainInstance().people.increment(property: "Card Count", by: 1)
            DataController.shared.installCard(forUserWithID: Auth.auth().currentUser!.uid, fromGlobalCard: currentCard, orderNumber: Int(truncating: currentCard.order ?? 0), newCard: { card in
                self.installed!.append(currentCard.cardID!)
                self.localCardCollection!.insert(card, at: self.localCardCollection!.count)
                if (self.localCardCollection!.count != 0 && self.doneButtonBackgroundView.isHidden) {
                    self.doneButtonLogic(shouldHide: false)
                }
                DispatchQueue.main.async {
                    UIView.transition(with: cell.checkBox, duration: 0.2, options: .transitionCrossDissolve, animations: {
                        cell.checkBox.image = #imageLiteral(resourceName: "checkbox_selected")
                    })
                }
            })
        } else {
            Mixpanel.mainInstance().track(event: "Deleted Card")
            Mixpanel.mainInstance().people.increment(property: "Card Count", by: -1)
            self.installed!.removeAll(where: {$0 == currentCard.cardID})
            guard let index = self.localCardCollection!.firstIndex(where: {$0.globalCardID == currentCard.cardID}) else { return }
            try? DataController.shared.deleteCardFromUser(card: self.localCardCollection![index])
            self.localCardCollection!.remove(at: index)
            if (self.localCardCollection!.count == 0 && !self.doneButtonBackgroundView.isHidden) {
                self.doneButtonLogic(shouldHide: true)
            }
            DispatchQueue.main.async {
                UIView.transition(with: cell.checkBox, duration: 0.2, options: .transitionCrossDissolve, animations: {
                    cell.checkBox.image = #imageLiteral(resourceName: "checkbox")
                })
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 86
    }
}

