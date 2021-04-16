//
//  HomeViewController.swift
//  Iris
//
//  Created by Shalin Shah on 1/4/20.
//  Copyright © 2020 Shalin Shah. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import Mapbox
import CoreData
import Mixpanel
import Alamofire
import MessageUI

class HomeViewController: UIViewController {
    var cardCollection: [Card]? = [Card]()
    var currentCard: [Card]? = [Card]()
    var animation: SentenceLoadingHUD!
    
    var animator: UIViewPropertyAnimator!
    var blurView: UIVisualEffectView!


    @IBOutlet weak var cardCollectionView: UICollectionView! {
        didSet {
            self.cardCollectionView.delegate = self
            self.cardCollectionView.dataSource = self
            self.cardCollectionView.layer.shouldRasterize = true
            self.cardCollectionView.layer.rasterizationScale = UIScreen.main.scale
        }
    }
    
    @IBOutlet weak var navigationCollectionView: UICollectionView! {
        didSet {
            self.navigationCollectionView.delegate = self
            self.navigationCollectionView.dataSource = self
            self.navigationCollectionView.contentInset = UIEdgeInsets(top: 0,left: 12,bottom: 0,right: 0)
            self.navigationCollectionView.layer.shouldRasterize = true
            self.navigationCollectionView.layer.rasterizationScale = UIScreen.main.scale
        }
    }
    
    var globalCardCollection: [GlobalCards]? = [GlobalCards]()
    var installed: [String]? = [String]()
    var navBarState: Int! = 0

    @IBOutlet weak var cardListTableView: UITableView! {
        didSet {
            self.cardListTableView.delegate = self
            self.cardListTableView.dataSource = self
            self.cardListTableView.layer.shouldRasterize = true
            self.cardListTableView.layer.rasterizationScale = UIScreen.main.scale
        }
    }
    
    @IBOutlet weak var draggableNavView: UIView! {
        didSet {
            self.draggableNavView.layer.shouldRasterize = true
            self.draggableNavView.layer.rasterizationScale = UIScreen.main.scale
        }
    }
    
    @IBOutlet weak var logoNav: UIButton! {
        didSet {
            self.logoNav.backgroundColor = .clear
            self.logoNav.layer.shadowColor = UIColor.black.cgColor
            self.logoNav.layer.shadowOpacity = 0.6
            self.logoNav.layer.shadowOffset = CGSize(width: 0, height: 0)
            self.logoNav.layer.shadowRadius = 10
            self.logoNav.layer.shadowPath = UIBezierPath(roundedRect: self.logoNav.bounds, cornerRadius: self.logoNav.frame.height/2).cgPath
            self.logoNav.layer.shouldRasterize = true
            self.logoNav.layer.rasterizationScale = UIScreen.main.scale
        }
    }
    
    @IBOutlet weak var curvedView: UIView! {
        didSet {
            self.curvedView.transform = CGAffineTransform(rotationAngle: .pi)
            self.curvedView.layer.shouldRasterize = true
            self.curvedView.layer.rasterizationScale = UIScreen.main.scale
        }
    }


    
    var sentence = [String]()
    var sentenceFormat = [String]()
    let kItemPadding = 5
    
    @IBOutlet weak var topView: CurvedUIView! {
        didSet {
            self.topView.layer.shouldRasterize = true
            self.topView.layer.rasterizationScale = UIScreen.main.scale
        }
    }
    
    @IBOutlet weak var sentenceCollectionView: UICollectionView! {
        didSet {
            self.sentenceCollectionView.delegate = self
            self.sentenceCollectionView.dataSource = self
            self.sentenceCollectionView.layer.shouldRasterize = true
            self.sentenceCollectionView.layer.rasterizationScale = UIScreen.main.scale
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                        
        if let flowlayout = self.navigationCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowlayout.itemSize = CGSize(width: 70, height: 82)
        }
        
        let screenHeight = UIScreen.main.bounds.size.height
        let screenWidht = UIScreen.main.bounds.size.width
        
        if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone) {
            if ( screenHeight == 812 && screenWidht == 375) {
                // iphone xs
                if let flowlayout = self.cardCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                    flowlayout.itemSize = CGSize(width: 375, height: 618)
                }
            } else if (screenHeight == 896 && screenWidht == 414) {
                // iphone x max
                if let flowlayout = self.cardCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                    flowlayout.itemSize = CGSize(width: 414, height: 701)
                }
            } else if (screenHeight == 736 && screenWidht == 414) {
                // iphone 7+ and 8+
                if let flowlayout = self.cardCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                    flowlayout.itemSize = CGSize(width: 414, height: 542)
                }
            } else {
                // iphone 7 and 8
                if let flowlayout = self.cardCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                    flowlayout.itemSize = CGSize(width: 375, height: 471)
                }
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appCameToForeground), name: UIApplication.didBecomeActiveNotification, object: nil)
                

        let bubbleLayout = BubbleCollection()
        bubbleLayout.minimumLineSpacing = 0.0
        bubbleLayout.minimumInteritemSpacing = 0.0
        bubbleLayout.delegate = self
        self.sentenceCollectionView.setCollectionViewLayout(bubbleLayout, animated: false)
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(wasDragged))
        self.draggableNavView.addGestureRecognizer(gesture)
        self.draggableNavView.isUserInteractionEnabled = true
        gesture.delegate = self
                
        self.getCardCollection()
        
        self.view.layer.shouldRasterize = true
        self.view.layer.rasterizationScale = UIScreen.main.scale
    }
    
    @objc func appMovedToBackground() {
        print("app enters background")
        self.blurView.removeFromSuperview()
    }
    
    @objc func appCameToForeground() {
        print("app enters foreground")
        self.animator = UIViewPropertyAnimator(duration: 0.1, curve: .linear)
        self.blurView = UIVisualEffectView(effect: nil)

        self.view.insertSubview(self.blurView, belowSubview: self.draggableNavView)
        self.blurView.frame = self.view.frame
        self.blurView.isHidden = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(blurViewTapped))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        self.blurView.addGestureRecognizer(tapGesture)

        animator.addAnimations {
            self.blurView.effect = UIBlurEffect(style: .dark)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    func cardsChanged() {
        self.cardCollection = [Card]()
        self.navigationCollectionView.reloadData()
        self.cardCollectionView.reloadData()
        self.getCardCollection()
    }
    
    func getCardCollection() {
        UserProfilesManager.fetchGlobalCards(db: Firestore.firestore(), response: { response in
            if response?.first?.cardName != "" {
                self.globalCardCollection = response ?? [GlobalCards]()
                DispatchQueue.main.async {
                    self.cardListTableView.reloadData()
                }
            } else {
                self.showAlert(message: nil, title: "Error fetching cards!", completionHandler: {_ in })
            }
        })
        
        let user = try? DataController.shared.getUser(fromID: Auth.auth().currentUser?.uid ?? "")
        let cards = try? DataController.shared.getCards(fromUser: user)
        if cards?.count ?? 0 > 0 {
            self.cardCollection = cards
            
            self.currentCard = [(cards?.first ?? Card(context: DataController.shared.context))]
            for card in cards ?? [Card]() {
                if (card.orderNumber == UserDefaults.standard.integer(forKey: "currentCard")) {
                    self.currentCard = [card]
                }
            }
            UserDefaults.standard.set(self.currentCard?.first?.orderNumber, forKey: "currentCard")

            let cardNameArray = self.cardCollection!.map { $0.cardName ?? "" }
            let ids = self.cardCollection?.map { $0.globalCardID }
            self.installed = ids as? [String]

            let cardOrder = cardNameArray.joined(separator:", ")
            Mixpanel.mainInstance().people.set(properties: ["Card Order": cardOrder])
        } else {
            self.showAlert(message: nil, title: "Error, you have no cards!", completionHandler: {_ in })
        }
    }
    
    func refreshSentence(response: Response) {
        self.sentence = response.sentence ?? [""]
        self.sentenceFormat = response.sentenceFormat ?? [""]
        self.reloadSentenceCollection()
    }
            
    func reloadSentenceCollection() {
        print("called many times")
        UIView.animate(withDuration: 0.05, delay: 0.0, options: .curveEaseInOut, animations: {
            self.sentenceCollectionView.alpha = 0.0
        }, completion: { finished in
            self.sentenceCollectionView.reloadData()
            self.sentenceCollectionView.reloadSections([0])
            self.sentenceCollectionView.contentInset.top = max((self.sentenceCollectionView.frame.height - self.sentenceCollectionView.contentSize.height) / 2, 0)
            UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseInOut, animations: {
                self.sentenceCollectionView.alpha = 1.0
            })
        })
    }

    func fixNavBarHighlight(indexPath: IndexPath) {
        self.navigationCollectionView.reloadData()
        self.navigationCollectionView.reloadSections([0])
    }
        
    func goToCardSettings(sentenceIndex: Int) {
        if (self.currentCard?.first?.tableData ?? false) {
            guard let cell = self.cardCollectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? TableCardCollectionViewCell else { return }
            let next: SettingsMultiSelectViewController? = self.storyboard?.instantiateViewController()
            next?.delegate = cell
            next!.settingGroupID = self.sentenceFormat[sentenceIndex]
            self.show(next!, sender: self)
        } else if (self.currentCard?.first?.accordionData ?? false) {
            guard let cell = self.cardCollectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? AccordionCardCollectionViewCell else { return }
            let next: ChoicesViewController? = self.storyboard?.instantiateViewController()
            next?.delegate = cell
            next!.settingGroupID = self.sentenceFormat[sentenceIndex]
            self.show(next!, sender: self)
        } else if (self.currentCard?.first?.mapData ?? false) {
            guard let cell = self.cardCollectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? MapCardCollectionViewCell else { return }
            let next: CardSettingsViewController? = self.storyboard?.instantiateViewController()
            next?.delegate = cell
            next!.settingSentenceIndex = sentenceIndex
            next!.currentSettingSentenceNickname = self.sentence[sentenceIndex]
            next!.settingGroupID = self.sentenceFormat[sentenceIndex]
            self.show(next!, sender: self)
        }
    }
    
    
    @IBAction func logoNavButton(_ sender: Any) {
        if (self.navBarState == 0) {
            self.moveDrawerMid()
        } else {
            self.moveDrawerDown()
        }
    }
    
    @IBAction func terms(_ sender: Any) {
        let next: ServiceViewController? = self.storyboard?.instantiateViewController()
        next?.mode = .terms
        self.show(next!, sender: self)
    }
    
    @IBAction func feedback(_ sender: Any) {
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = ""
            controller.recipients = ["9498362723", "9499396619", "8182033202"]
            controller.messageComposeDelegate = self
            self.show(controller, sender: self)
        }
    }

    @IBAction func privacy(_ sender: Any) {
        let next: ServiceViewController? = self.storyboard?.instantiateViewController()
        next?.mode = .privacy
        self.show(next!, sender: self)
    }

    
    @objc func blurViewTapped() {
        self.moveDrawerDown()
    }
}

extension HomeViewController: MapCardCollectionViewCellDelegate, TableCardCollectionViewCellDelegate, AccordionCardCollectionViewCellDelegate {
    func cardRefreshing() {

    }
    
    func addAnimation() {
        self.animation = self.addSentenceAnimation(view: self.sentenceCollectionView)
        self.logoNav.rotate()
    }
    
    func removeAnimation() {
        self.removeSentenceAnimation(loader: self.animation)
        self.logoNav.stopRotating()
    }
    
    func sentenceSettingEdited(response: Response!, index: Int!, nickname: String!) {
        let cell = self.sentenceCollectionView.cellForItem(at: IndexPath(row: index, section: 0)) as! GradientSentenceCollectionView
        cell.word.text = nickname
        self.sentence[index] = nickname
        self.reloadSentenceCollection()
        try? DataController.shared.updateResponseSentence(response: response, sentence: self.sentence)
    }

    func updateSentence(response: Response) {
        self.refreshSentence(response: response)
    }
        
    func cardRefreshed() {

    }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, BubbleCollectionDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (collectionView == self.cardCollectionView) {
            return self.currentCard?.count ?? 0
        }
        
        if (collectionView == self.sentenceCollectionView) {
            return self.sentence.count
        }
        
        return self.cardCollection?.count ?? 0
    }
        
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (collectionView == self.cardCollectionView) {
            if (self.currentCard?.first?.tableData ?? false) {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TableCardCollectionViewCell", for: indexPath as IndexPath) as! TableCardCollectionViewCell
                cell.cardID = self.currentCard?.first?.cardID
                cell.delegate = self
                
                cell.clearEverything()
                cell.refreshSequence()

                return cell
            } else if (self.currentCard?.first?.accordionData ?? false) {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AccordionCardCollectionViewCell", for: indexPath as IndexPath) as! AccordionCardCollectionViewCell
                cell.cardID = self.currentCard?.first?.cardID
                cell.delegate = self
                
                cell.clearEverything()
                cell.refreshSequence()
                
                return cell
            } else if (self.currentCard?.first?.mapData ?? false) {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MapCardCollectionViewCell", for: indexPath as IndexPath) as! MapCardCollectionViewCell
                cell.cardID = self.currentCard?.first?.cardID
                cell.delegate = self

                cell.clearEverything()
                cell.refreshSequence()

                return cell
            }
        }
        
        if (collectionView == self.sentenceCollectionView) {
            if (self.sentenceFormat[indexPath.item] == "none") {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NormalSentenceCollectionViewCell", for: indexPath as IndexPath) as! NormalSentenceCollectionViewCell
                
                cell.word.text = self.sentence[indexPath.item]
                let width = self.sentence[indexPath.item].width(withConstrainedHeight: cell.word.frame.height, font: UIFont(name: "NunitoSans-SemiBold", size: 28) ?? UIFont())
                cell.word.frame = CGRect(x: 4, y: 0, width: width + 4, height: cell.word.frame.height)

                cell.word.textColor = .white
                            
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GradientSentenceCollectionView", for: indexPath as IndexPath) as! GradientSentenceCollectionView
                
                cell.word.text = self.sentence[indexPath.item]
                let width = self.sentence[indexPath.item].width(withConstrainedHeight: cell.word.frame.height, font: UIFont(name: "NunitoSans-SemiBold", size: 28) ?? UIFont())
                cell.word.frame = CGRect(x: 4, y: 0, width: width + 4, height: cell.word.frame.height)
                cell.edit.frame = CGRect(x: width + 5, y: 9, width: cell.edit.frame.width, height: cell.edit.frame.height)

                cell.bgView.frame = cell.word.bounds

                let gradient = CAGradientLayer()
                gradient.colors = [UIColor(displayP3Red: 249.0/255.0, green: 59.0/255.0, blue: 118.0/255.0, alpha: 1.0).cgColor, UIColor(displayP3Red: 188.0/255.0, green: 63.0/255.0, blue: 188.0/255.0, alpha: 1.0).cgColor]
                gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
                gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
                gradient.frame = cell.bgView.bounds
                cell.bgView.layer.addSublayer(gradient)
                cell.bgView.addSubview(cell.word)
                
                cell.bgView.layer.mask = cell.word.layer
                
                return cell
            }
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NavigationCollectionViewCell", for: indexPath as IndexPath) as! NavigationCollectionViewCell
        cell.title.text = self.cardCollection?[indexPath.item].cardName?.firstUppercased
        cell.icon.image = UIImage.getImage(self.cardCollection?[indexPath.item].icon ?? "none", sideLength: 40.0, color: .white)

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (collectionView == self.navigationCollectionView) {
            guard let newCard = self.cardCollection?[indexPath.item] else { return }
            // If Visible Cell is the same as the one that's been scrolled to, do nothing
            print(newCard.orderNumber)
            if (newCard.orderNumber == UserDefaults.standard.integer(forKey: "currentCard")) { self.moveDrawerDown(); return }
            

            UserDefaults.standard.set(newCard.orderNumber, forKey: "currentCard")
            self.currentCard = [Card]()
            self.currentCard?.append(newCard)
    
            // Otherwise refresh the cell with new content
            self.fixNavBarHighlight(indexPath: indexPath)
            
            if (self.cardCollection?[indexPath.item].mapData ?? false) {
                self.cardCollectionView.reloadData()
            } else {
                UIView.animate(withDuration: 0.05, delay: 0.0, options: .curveEaseInOut, animations: {
                    self.cardCollectionView.alpha = 0.0
                }, completion: { finished in
                    self.cardCollectionView.reloadData()
                    self.cardCollectionView.reloadSections([0])
                    UIView.animate(withDuration: 0.05, delay: 0.1, options: .curveEaseInOut, animations: {
                        self.cardCollectionView.alpha = 1.0
                    })
                })
            }
            self.sentence = [String]()
            self.sentenceFormat = [String]()
            self.sentenceCollectionView.reloadData()
            
            self.moveDrawerDown()
        }
        
        if (collectionView == self.sentenceCollectionView) {
            if (self.sentenceFormat[indexPath.item] != "none") {
                DispatchQueue.main.async {
                    self.goToCardSettings(sentenceIndex: indexPath.item)
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, itemSizeAt indexPath: NSIndexPath) -> CGSize {
        if (collectionView == self.sentenceCollectionView) {
            let title = self.sentence[indexPath.item]
            var size: CGSize = title.size(withAttributes: [.font: UIFont(name: "NunitoSans-Regular", size: 28)!])

            if self.sentenceFormat[indexPath.item] != "none" { size.width = CGFloat(size.width + 24) }
            size.width = CGFloat(ceilf(Float(size.width + CGFloat(kItemPadding * 2))))
            size.height = 38

            if size.width > collectionView.frame.size.width {
                size.width = collectionView.frame.size.width
            }

            return size
        }
        return CGSize()
    }
}

extension HomeViewController: UIGestureRecognizerDelegate {
    @objc func wasDragged(gestureRecognizer: UIPanGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizer.State.changed {
            let translation = gestureRecognizer.translation(in: self.view)
            print(gestureRecognizer.view!.center.y)
            if (gestureRecognizer.view!.center.y >= self.view.frame.size.height - (self.draggableNavView.frame.size.height/2)) {
                gestureRecognizer.view?.center = CGPoint(
                  x: gestureRecognizer.view!.center.x,
                  y: max(gestureRecognizer.view!.center.y + translation.y, self.view.frame.size.height - (self.draggableNavView.frame.size.height/2))
                )
                
                let translation = gestureRecognizer.translation(in: self.view)
                let screenHeight = UIScreen.main.bounds.size.height
                let screenWidht = UIScreen.main.bounds.size.width

                var startPoint: CGFloat = self.view.frame.size.height - 80
                if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone) {
                    if ( screenHeight == 812 && screenWidht == 375) || (screenHeight == 896 && screenWidht == 414){
                        startPoint = self.view.frame.size.height - 100
                    } else {
                        // iphone 7 and 8
                        startPoint = self.view.frame.size.height - 80
                    }
                }

                self.animator.fractionComplete = (gestureRecognizer.view!.frame.origin.y - startPoint) / (self.view.frame.size.height - self.draggableNavView.frame.size.height - startPoint)
                self.blurView.isHidden = false
            }
            gestureRecognizer.setTranslation(CGPoint(x: 0,y: 0), in: self.view)
        } else if gestureRecognizer.state == UIGestureRecognizer.State.ended {
            let velocity = gestureRecognizer.velocity(in: self.view)

            if (self.navBarState == 0) {
                // at the bottom
                if velocity.y >= 1500 || self.draggableNavView.frame.origin.y > self.view.frame.size.height - 160 {
                    self.moveDrawerDown()
                } else if self.draggableNavView.frame.origin.y > self.view.frame.size.height - 320 {
                    self.moveDrawerMid()
                } else {
                    self.moveDrawerUp()
                }
            } else if (self.navBarState == 1) {
                // at the mid
                if velocity.y >= 1500 || self.draggableNavView.frame.origin.y > self.view.frame.size.height - 280 {
                    self.moveDrawerDown()
                } else if self.draggableNavView.frame.origin.y > self.view.frame.size.height - 320 {
                    self.moveDrawerMid()
                } else {
                    self.moveDrawerUp()
                }
            } else {
                // at the top
                if velocity.y >= 1500 || self.draggableNavView.frame.origin.y > self.view.frame.size.height - 160 {
                    self.moveDrawerDown()
                } else if self.draggableNavView.frame.origin.y > self.view.frame.size.height - self.draggableNavView.frame.size.height + 60 {
                    self.moveDrawerMid()
                } else {
                    self.moveDrawerUp()
                }
            }
        }
    }
    
    func moveDrawerDown() {
        self.navBarState = 0
        UIView.animate(withDuration: 0.2
          , animations: {
            self.animator.fractionComplete = 0.0
            self.blurView.isHidden = true
            let bottomPoint = self.view.frame.size.height - 80
            self.draggableNavView.frame.origin = CGPoint(
              x: self.draggableNavView.frame.origin.x,
              y: bottomPoint
            )
          }, completion: nil)
    }
    
    func moveDrawerMid() {
        self.navBarState = 1
        UIView.animate(withDuration: 0.2 , animations: {
            let startPoint = self.view.frame.size.height - 80
            let currPos = self.view.frame.size.height - (self.draggableNavView.frame.size.height*0.41)
            self.animator.fractionComplete = (currPos - startPoint) / (self.view.frame.size.height - self.draggableNavView.frame.size.height - startPoint)
            self.blurView.isHidden = false
            self.draggableNavView.frame.origin = CGPoint(
                x: self.draggableNavView.frame.origin.x,
                y: self.view.frame.size.height - (self.draggableNavView.frame.size.height*0.41)
            )
        }, completion: nil)
    }
    
    func moveDrawerUp() {
        self.navBarState = 2
        UIView.animate(withDuration: 0.2 , animations: {
            self.animator.fractionComplete = 1.0
            self.blurView.isHidden = false
            self.draggableNavView.frame.origin = CGPoint(
                x: self.draggableNavView.frame.origin.x,
                y: self.view.frame.size.height - (self.draggableNavView.frame.size.height)
            )
        }, completion: nil)
    }
}


extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
        
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.globalCardCollection?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.cardListTableView.dequeueReusableCell(withIdentifier: "CardInstallTableViewCell", for: indexPath as IndexPath) as! CardInstallTableViewCell
                
        cell.title.text = self.globalCardCollection?[indexPath.row].cardName
        cell.subLabel.text = self.globalCardCollection?[indexPath.row].cardDescription
        cell.subLabel.frame = CGRect(x: cell.subLabel.frame.minX, y: cell.subLabel.frame.minY, width: 225, height: cell.subLabel.frame.height)
        cell.icon.image = UIImage.getImage(self.globalCardCollection?[indexPath.row].icon ?? "none", sideLength: 30.0, color: .white)

        if (self.installed?.contains(self.globalCardCollection?[indexPath.row].cardID ?? "") ?? false) {
            cell.checkBox.image = #imageLiteral(resourceName: "checkbox_selected")
        } else {
            cell.checkBox.image = #imageLiteral(resourceName: "checkbox")
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.globalCardCollection?.count == 0 { return }
        
        guard let currentCard = self.globalCardCollection?[indexPath.row] else { return }
        guard let cell = self.cardListTableView.cellForRow(at: IndexPath(row: indexPath.row, section: 0)) as? CardInstallTableViewCell else { return }

        if (!(self.installed?.contains(self.globalCardCollection?[indexPath.row].cardID ?? "") ?? true)) {
            //
            // install the card from here
            //
            Mixpanel.mainInstance().track(event: "Added Card")
            Mixpanel.mainInstance().people.increment(property: "Card Count", by: 1)
            DataController.shared.installCard(forUserWithID: Auth.auth().currentUser!.uid, fromGlobalCard: currentCard, orderNumber: Int(truncating: currentCard.order ?? 0), newCard: { card in
                self.installed!.append(currentCard.cardID!)
                self.cardCollection!.insert(card, at: self.cardCollection!.count)
                DispatchQueue.main.async {
                    self.cardsChanged()
                    UIView.transition(with: cell.checkBox, duration: 0.2, options: .transitionCrossDissolve, animations: {
                        cell.checkBox.image = #imageLiteral(resourceName: "checkbox_selected")
                    })
                }
            })
        } else {
            if (self.cardCollection?.count ?? 0 < 2) { return }
            Mixpanel.mainInstance().track(event: "Deleted Card")
            Mixpanel.mainInstance().people.increment(property: "Card Count", by: -1)
            self.installed!.removeAll(where: {$0 == currentCard.cardID})
            guard let index = self.cardCollection?.firstIndex(where: {$0.globalCardID == currentCard.cardID}) else { return }
            try? DataController.shared.deleteCardFromUser(card: self.cardCollection![index])
            self.cardCollection!.remove(at: index)
            DispatchQueue.main.async {
                self.cardsChanged()
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

extension HomeViewController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true)
    }
}
