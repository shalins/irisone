//
//  CardSettingsViewController.swift
//  Iris
//
//  Created by Shalin Shah on 1/17/20.
//  Copyright © 2020 Shalin Shah. All rights reserved.
//

import UIKit
import FirebaseAuth
import CoreData
import Mixpanel

protocol CardSettingsViewControllerDelegate: class {
    func newSettingSelected()
    func settingNameEdited(index: Int!, nickname: String!)
}

class CardSettingsViewController: PannableViewController {

    var settingsGroup: Setting_Group?
    var settingGroupID: String! = ""
    var settingSentenceIndex: Int! // this is for if I edit any nicknames
    var currentSettingSentenceNickname: String!
    var settings: [Setting]? = [Setting]()
    
    weak var delegate: CardSettingsViewControllerDelegate?
    
    @IBOutlet weak var settingsTableView: UITableView! {
        didSet {
            self.settingsTableView.delegate = self
            self.settingsTableView.dataSource = self
            self.settingsTableView.layer.shouldRasterize = true
            self.settingsTableView.layer.rasterizationScale = UIScreen.main.scale
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
    
    @IBOutlet weak var modifierHeader: UILabel! {
        didSet {
            self.modifierHeader.layer.shouldRasterize = true
            self.modifierHeader.layer.rasterizationScale = UIScreen.main.scale
        }
    }
    
    @IBOutlet weak var modifierButton: UIButton! {
        didSet {
            self.modifierButton.makeCorner(withRadius: 8)
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
        
        self.getSettings()

        self.view.layer.shouldRasterize = true
        self.view.layer.rasterizationScale = UIScreen.main.scale
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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

        if (settingsGroup.tag == "common_locations") {
            Mixpanel.mainInstance().people.set(properties: ["Common Locations Count": settings?.count ?? 0])
        }
        
        if settings?.count ?? 0 > 0 {
            self.settings = settings!
            self.displaySettings()
        } else {
            self.showAlert(message: nil, title: "Error, you have no cards!", completionHandler: {_ in })
        }
    }
    
    func displaySettings() {
        self.settingsTableView.reloadData()

        if (settingsGroup?.modifierFormat == "search_location_single") {
            self.modifierButton.addTarget(self, action: #selector(modifierButtonPressed(_:)), for: .touchUpInside)
        }
        if (self.settingsGroup?.selectorHeader![0] != "none") {
            self.selectorHeader.text = self.settingsGroup?.selectorHeader![0]
        }
        if (self.settingsGroup?.modifierHeader![0] != "none") {
            self.modifierHeader.text = self.settingsGroup?.modifierHeader![0]
        }
    }
    
    func changeSetting(selectedIndex: Int) {
        var index = 0
        guard let settings = self.settings else { return }
        for setting in settings {
            if (setting.selected) {
                setting.selected = false
            }
            if (index == selectedIndex) {
                setting.selected = true
            }
            index = index + 1
        }
    }
    
    func newSettingSelectedSequence() {
        DispatchQueue.main.async {
            self.delegate?.newSettingSelected()
            self.dismiss(animated: true, completion: nil)
        }
    }

    
    @objc func modifierButtonPressed(_ sender: Any) {
        DispatchQueue.main.async {
            let next: SettingsDetailViewController? = self.storyboard?.instantiateViewController()
            next?.modalPresentationStyle = .fullScreen
            next?.settingsGroup = self.settingsGroup
            next?.delegate = self
            self.show(next!, sender: self)
        }
    }
}

extension CardSettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.settings?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.settingsTableView.dequeueReusableCell(withIdentifier: "CardSettingsTableViewCell", for: indexPath as IndexPath) as! CardSettingsTableViewCell
                
        cell.title.text = self.settings?[indexPath.row].displayVal![0]
        
        if (self.settingsGroup?.selectorEditable ?? false) {
            cell.editButton.isHidden = false
            cell.editButton.addTarget(self, action: #selector(edited(sender:)), for: .touchUpInside)
            cell.editButton.tag = indexPath.row
        } else {
            cell.editButton.isHidden = true
        }
                
        if (self.settingsGroup?.selectorRemovable ?? false) {
            cell.deleteButton.isHidden = false
            cell.deleteButton.addTarget(self, action: #selector(deleted(sender:)), for: .touchUpInside)
            cell.deleteButton.tag = indexPath.row
        } else {
            cell.deleteButton.isHidden = true
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let settingTitle = self.settings?[indexPath.row].displayVal?[0]
        if (self.settings?[indexPath.row].selected ?? false) && (currentSettingSentenceNickname.lowercased() == settingTitle?.lowercased()) {
            // setting was already selected
            self.dismiss(animated: true, completion: nil)
        } else {
            self.changeSetting(selectedIndex: indexPath.row)
            self.newSettingSelectedSequence()
        }
    }
    
    @objc func edited(sender: UIButton) {
        DispatchQueue.main.async {
            let buttonTag = sender.tag
            let settingTitle = self.settings?[buttonTag].displayVal?[0]
            
            let alertController = UIAlertController(title: "Change a nickname", message: "", preferredStyle: UIAlertController.Style.alert)
            alertController.addTextField { (textField : UITextField!) -> Void in
                textField.text = settingTitle
            }
            let saveAction = UIAlertAction(title: "Save", style: UIAlertAction.Style.default, handler: { alert -> Void in
                guard let text = alertController.textFields![0].text else { return }
                var newArray = self.settings?[buttonTag].displayVal!
                newArray?[0] = text
                try? DataController.shared.updateSettingName(setting: self.settings?[buttonTag] ?? Setting(context: DataController.shared.context), newValue: newArray)

                self.settings?[buttonTag].displayVal = newArray

                self.settingsTableView.reloadData()
//                self.settingsTableView.reloadSections([0], with: UITableView.RowAnimation.none)
                if (self.settings?[buttonTag].selected ?? false) {
                    self.delegate?.settingNameEdited(index: self.settingSentenceIndex, nickname: text)
                }
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: {
                (action : UIAlertAction!) -> Void in })

            alertController.addAction(saveAction)
            alertController.addAction(cancelAction)

            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @objc func deleted(sender: UIButton) {
        let buttonTag = sender.tag
        if (self.settings?.count ?? 0 <= 1) {
            self.showAlert(message: nil, title: "Only one setting!", completionHandler: { _ in return })
        } else {
            
            let isSettingSelected = self.settings?[buttonTag].selected ?? false
                        
            // if it's the only setting that's selected, then change the selected to something else
            try? DataController.shared.deleteSettingfromSettingsGroup(setting: self.settings?[buttonTag] ?? Setting(context: DataController.shared.context))
            self.settings?.remove(at: buttonTag)
            self.settingsTableView.deleteRows(at: [IndexPath(row: buttonTag, section: 0)], with: .fade)
            self.settingsTableView.reloadData()
            
            if isSettingSelected {
                try? DataController.shared.updateSettingSelected(setting: self.settings?[0] ?? Setting(context: DataController.shared.context), selected: true)
                self.newSettingSelectedSequence()
            }
        }
    }
}

extension CardSettingsViewController: SettingsDetailViewControllerDelegate {
    func addedNewPlace() {
        self.getSettings()
    }
}

extension CardSettingsViewController: UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
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


