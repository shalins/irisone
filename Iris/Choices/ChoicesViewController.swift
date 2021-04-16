//
//  ChoicesViewController.swift
//  Iris
//
//  Created by Shalin Shah on 1/12/20.
//  Copyright © 2020 Shalin Shah. All rights reserved.
//

import Foundation
import FirebaseAuth
import UIKit
import SpotifyLogin
import Mixpanel

protocol ChoicesViewControllerDelegate: class {
    func newSettingSelected()
}

class ChoicesViewController: PannableViewController {

    var settingsGroup: Setting_Group?
    var settingGroupID: String! = ""
    var settings: [Setting]? = [Setting]()
    let kItemPadding = 10

    weak var delegate: ChoicesViewControllerDelegate?

    @IBOutlet weak var choicesCollectionView: UICollectionView! {
        didSet {
            self.choicesCollectionView.delegate = self
            self.choicesCollectionView.dataSource = self
            self.choicesCollectionView.layer.shouldRasterize = true
            self.choicesCollectionView.layer.rasterizationScale = UIScreen.main.scale
        }
    }
    
    @IBOutlet weak var roundedView: UIView! {
        didSet {
            self.roundedView.addTopRoundedEdge(desiredCurve: 1.0)
            self.roundedView.layer.shouldRasterize = true
            self.roundedView.layer.rasterizationScale = UIScreen.main.scale
        }
    }

    @IBOutlet weak var drawer: UIView! {
        didSet {
            self.drawer.makeCorner(withRadius: self.drawer.frame.height/2)
            self.drawer.layer.shouldRasterize = true
            self.drawer.layer.rasterizationScale = UIScreen.main.scale
        }
    }
    
    @IBOutlet weak var selectorHeader: UILabel! {
        didSet {
            self.selectorHeader.layer.shouldRasterize = true
            self.selectorHeader.layer.rasterizationScale = UIScreen.main.scale
        }
    }
    
    @IBOutlet weak var authButton: UIButton! {
        didSet {
            self.authButton.isHidden = true
            self.authButton.layer.shouldRasterize = true
            self.authButton.layer.rasterizationScale = UIScreen.main.scale
        }
    }
    
    @IBOutlet weak var modifierHeader: UILabel! {
        didSet {
            self.modifierHeader.isHidden = true
            self.modifierHeader.layer.shouldRasterize = true
            self.modifierHeader.layer.rasterizationScale = UIScreen.main.scale
        }
    }
    
    @IBOutlet weak var modifierButton: UIButton! {
        didSet {
            self.modifierButton.isHidden = true
            self.modifierButton.layer.shouldRasterize = true
            self.modifierButton.layer.rasterizationScale = UIScreen.main.scale
        }
    }


    lazy var backdropView: UIView = {
        let bdView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height/2))
        bdView.backgroundColor = UIColor.black.withAlphaComponent(0.01)
        return bdView
    }()

    let menuView = UIView()
    let menuHeight = UIScreen.main.bounds.height / 2
    var isPresenting = false
    

    init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        view.backgroundColor = .clear
        view.addSubview(backdropView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        backdropView.addGestureRecognizer(tapGesture)
        
        let bubbleLayout = BubbleCollection()
        bubbleLayout.minimumLineSpacing = 6.0
        bubbleLayout.minimumInteritemSpacing = 10.0
        bubbleLayout.delegate = self
        self.choicesCollectionView.setCollectionViewLayout(bubbleLayout, animated: false)
        
        self.getSettings()

        self.view.layer.shouldRasterize = true
        self.view.layer.rasterizationScale = UIScreen.main.scale
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }

    
    func getSettings() {
        guard let settingsGroup = try? DataController.shared.getSettingsGroup(fromID: self.settingGroupID) else {
            self.showAlert(message: nil, title: "Error, you have no cards!", completionHandler: {_ in })
            return
        }
        
        self.settingsGroup = settingsGroup
        
        let settings = try? DataController.shared.getSettingsByTypeSelector(fromGroup: settingsGroup)
        
        if (settingsGroup.tag == "cost_threshold") {
            let selected = settings!.filter { $0.selected == true && $0.type == "selector"}
            Mixpanel.mainInstance().people.set(properties: ["Cost Threshold": selected.first?.displayVal?.first ?? ""])
        } else if (settingsGroup.tag == "diet") {
            let selected = settings!.filter { $0.selected == true && $0.type == "selector"}
            Mixpanel.mainInstance().people.set(properties: ["Diet": selected.first?.displayVal?.first ?? ""])
        } else if (settingsGroup.tag == "dining_halls") {
           let selected = settings!.filter { $0.selected == true && $0.type == "selector"}
            Mixpanel.mainInstance().people.set(properties: ["Dining Hall": selected.first?.displayVal?.first ?? ""])
        }

        if settings?.count ?? 0 > 0 {
            self.settings = settings!
            self.displaySettings()
        } else {
            self.showAlert(message: nil, title: "Error, you have no cards!", completionHandler: {_ in })
        }
    }
    
    func displaySettings() {
        if self.settingsGroup?.selectorFormat == "spotify_auth" {
            self.authButton.isHidden = false
            self.choicesCollectionView.isHidden = true
        } else {
            self.authButton.isHidden = true
            self.choicesCollectionView.reloadData()
            self.choicesCollectionView.reloadSections([0])
        }

        if (self.settingsGroup?.selectorHeader![0] != "none") {
            self.selectorHeader.text = self.settingsGroup?.selectorHeader![0]
        }
        
        if (settingsGroup?.modifierFormat == "select_multi") {
            self.modifierButton.isHidden = false
            self.modifierButton.setImage(#imageLiteral(resourceName: "select_settings"), for: .normal)
            self.modifierButton.addTarget(self, action: #selector(modifierButtonPressed(_:)), for: .touchUpInside)
        }
        if (self.settingsGroup?.modifierHeader![0] != "none") {
            self.modifierHeader.isHidden = false
            self.modifierHeader.text = self.settingsGroup?.modifierHeader![0]
        }

    }
    
    func changeSetting(selectedIndex: Int) {
        var index = 0
        for setting in self.settings ?? [Setting]() {
            if (setting.selected) {
                setting.selected = false
            }
            if (index == selectedIndex) {
                setting.selected = true
            }
            index = index + 1
        }
    }
    
    @objc func modifierButtonPressed(_ sender: Any) {
        DispatchQueue.main.async {
            let next: SettingsMultiSelectViewController? = self.storyboard?.instantiateViewController()
            next?.modalPresentationStyle = .fullScreen
            next?.settingGroupID = self.settingsGroup?.settingsGroupID
            next?.delegate = self
            self.show(next!, sender: self)
        }
    }
    
    @IBAction func authButtonPressed() {
        if self.settingsGroup?.selectorFormat == "spotify_auth" {
            SpotifyLogin.shared.getAccessToken { (accessToken, error) in
                if error != nil {
                    // User is not logged in, show log in flow.
                    SpotifyLoginPresenter.login(from: self, scopes: [.userReadTop])
                    NotificationCenter.default.addObserver(self, selector: #selector(self.loginSuccessful), name: .SpotifyLoginSuccessful, object: nil)
                } else {
                    guard let user = try? DataController.shared.getUser(fromID: Auth.auth().currentUser?.uid ?? "") else { return }
                    try? DataController.shared.updateUserSpotifyToken(user: user, spotifyToken: accessToken ?? "")
                    self.showAlert(message: nil, title: "Already signed in!", completionHandler: {completed in
                        self.dismiss(animated: true, completion: nil)
                    })
                }
            }
        }
    }
    
    @objc func loginSuccessful() {
        SpotifyLogin.shared.getAccessToken { (accessToken, error) in
            if error != nil {
                // User is not logged in, show log in flow.
            } else {
                // user is logged in
                Mixpanel.mainInstance().people.set(properties: ["Spotify Allowed": true])
                guard let user = try? DataController.shared.getUser(fromID: Auth.auth().currentUser?.uid ?? "") else { return }
                try? DataController.shared.updateUserSpotifyToken(user: user, spotifyToken: accessToken ?? "")
                self.newSettingSelectedSequence()
            }
        }
    }
    
    func newSettingSelectedSequence() {
        self.delegate?.newSettingSelected()
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension ChoicesViewController: SettingsMultiSelectViewControllerDelegate {
    func settingsChanged() {
        self.newSettingSelectedSequence()
    }
}


extension ChoicesViewController: UICollectionViewDelegate, UICollectionViewDataSource, BubbleCollectionDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.settings?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChoicesCollectionViewCell", for: indexPath as IndexPath) as! ChoicesCollectionViewCell
        
        cell.title.text = self.settings?[indexPath.row].displayVal![0]
        cell.contentView.backgroundColor = (self.settings?[indexPath.row].selected ?? false) ? UIColor.ColorTheme.Blue.Electric : UIColor.ColorTheme.Blue.Mirage
        
        cell.title.sizeToFit()

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.changeSetting(selectedIndex: indexPath.row)
            self.newSettingSelectedSequence()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, itemSizeAt indexPath: NSIndexPath) -> CGSize {
        
        let title = self.settings?[indexPath.item].displayVal?.first
        var size: CGSize = title?.size(withAttributes: [.font: UIFont(name: "Avenir-Medium", size: 20)!]) ?? CGSize()

        size.width = CGFloat(ceilf(Float(size.width + CGFloat(kItemPadding * 2))))
        size.height = 49
        
        if size.width > collectionView.frame.size.width {
            size.width = collectionView.frame.size.width
        }
        
        return size
    }
    
}

extension ChoicesViewController: UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        guard let toVC = toViewController else { return }
        isPresenting = !isPresenting

        if isPresenting == true {
            containerView.addSubview(toVC.view)

            menuView.frame.origin.y += menuHeight
            backdropView.alpha = 0

            UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseOut], animations: {
                self.menuView.frame.origin.y -= self.menuHeight
                self.backdropView.alpha = 1
            }, completion: { (finished) in
                transitionContext.completeTransition(true)
            })
        } else {
            UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseOut], animations: {
                self.menuView.frame.origin.y += self.menuHeight
                self.backdropView.alpha = 0
            }, completion: { (finished) in
                transitionContext.completeTransition(true)
            })
        }
    }
}

