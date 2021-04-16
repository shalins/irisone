//
//  SettingsMultiSelectViewController.swift
//  Iris
//
//  Created by Shalin Shah on 1/22/20.
//  Copyright © 2020 Shalin Shah. All rights reserved.
//

import UIKit
import Mixpanel

protocol SettingsMultiSelectViewControllerDelegate: class {
    func settingsChanged()
}

class SettingsMultiSelectViewController: UIViewController {
    
    var settingsGroup: Setting_Group?
    var settingGroupID: String! = ""
    var optionsChanged: Bool! = false

    var settings: [Setting]? = [Setting]()
    var selectedSettingTitles: [String]? = [String]()
    var filteredSettings: [Setting]? = [Setting]()
    var isSeachBarAnimationCompleted: Bool = false

    weak var delegate: SettingsMultiSelectViewControllerDelegate?

    @IBOutlet weak var searchView: UIView! {
        didSet {
            self.searchView.layer.shouldRasterize = true
            self.searchView.layer.rasterizationScale = UIScreen.main.scale
        }
    }
    let searchController = UISearchController(searchResultsController: nil)

    @IBOutlet weak var modifierHeader: UILabel! {
        didSet {
            self.modifierHeader.layer.shouldRasterize = true
            self.modifierHeader.layer.rasterizationScale = UIScreen.main.scale
        }
    }

    
    @IBOutlet weak var settingsMultiSelectTableView: UITableView! {
        didSet {
            self.settingsMultiSelectTableView.delegate = self
            self.settingsMultiSelectTableView.dataSource = self
            self.settingsMultiSelectTableView.layer.shouldRasterize = true
            self.settingsMultiSelectTableView.layer.rasterizationScale = UIScreen.main.scale
        }
    }
    
    
    @IBOutlet weak var doneButtonBackgroundView: UIView! {
        didSet {
            self.doneButtonBackgroundView.isHidden = true
            self.doneButtonBackgroundView.layer.shouldRasterize = true
            self.doneButtonBackgroundView.layer.rasterizationScale = UIScreen.main.scale
        }
    }
    
    @IBOutlet weak var cancelButton: UIButton! {
        didSet {
            self.cancelButton.layer.shouldRasterize = true
            self.cancelButton.layer.rasterizationScale = UIScreen.main.scale
        }
    }

    
    @IBOutlet weak var doneButton: UIButton! {
        didSet {
            self.doneButton.makeCorner(withRadius: 8)
            self.doneButton.backgroundColor = UIColor(displayP3Red: 3/255.0, green: 0/255.0, blue: 153/255.0, alpha: 1.0)
            self.doneButton.layer.shouldRasterize = true
            self.doneButton.layer.rasterizationScale = UIScreen.main.scale
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        self.searchController.searchBar.placeholder = "Filter"
        self.searchController.searchBar.searchBarStyle = .minimal
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.obscuresBackgroundDuringPresentation = false

        let image = self.getImageWithColor(color: UIColor.ColorTheme.Blue.Mirage, size: CGSize(width: 20, height: 46))
        self.searchController.searchBar.setSearchFieldBackgroundImage(image, for: .normal)
        
        if let textfield = self.searchController.searchBar.value(forKey: "searchField") as? UITextField {
            textfield.font = UIFont(name: "NunitoSans-Regular", size: 16.0)!
            let imageView:UIImageView = UIImageView.init(image: #imageLiteral(resourceName: "searchicon"))
            imageView.frame = CGRect(x: 0, y: 0, width: (imageView.image?.size.width ?? 0), height: (imageView.image?.size.height ?? 0))
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 25))
            paddingView.addSubview(imageView)
            textfield.leftView = paddingView

            if let backgroundview = textfield.subviews.first {
                backgroundview.backgroundColor = UIColor.clear
                backgroundview.layer.cornerRadius = 8
                backgroundview.clipsToBounds = true
            }
            textfield.textColor = UIColor.white
        }
        
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([NSAttributedString.Key.font : UIFont(name: "NunitoSans-Regular", size: 16.0)!, NSAttributedString.Key.foregroundColor: UIColor.darkGray], for: .normal)
        
        let placeholderAppearance = UILabel.appearance(whenContainedInInstancesOf: [UISearchBar.self])
        placeholderAppearance.padding = UIEdgeInsets(top: 2, left: 50, bottom: 0, right: 0)
        placeholderAppearance.textColor = UIColor.ColorTheme.Gray.Silver

        self.definesPresentationContext = false
        self.searchView.addSubview(self.searchController.searchBar)
        
        self.searchController.delegate = self
        self.searchController.searchBar.delegate = self
        self.searchController.searchResultsUpdater = self

        
        self.view.layer.shouldRasterize = true
        self.view.layer.rasterizationScale = UIScreen.main.scale
        self.getSettings()
    }
    
    deinit {
        self.searchController.searchResultsUpdater = nil
        self.searchController.searchBar.delegate = nil
        self.searchController.delegate = nil
    }
    
    func getSettings() {
        guard let settingsGroup = try? DataController.shared.getSettingsGroup(fromID: self.settingGroupID) else {
            self.showAlert(message: nil, title: "Error, you have no settings!", completionHandler: {_ in })
            return
        }
        self.settingsGroup = settingsGroup
                
        var settings: [Setting]?
        if (settingsGroup.tag == "study_spots") {
            let selectedSettings = (try? DataController.shared.getSettingsBySelected(fromGroup: settingsGroup)) ?? [Setting]()

            for setting in selectedSettings {
                self.selectedSettingTitles?.append(setting.displayVal?[0] ?? "")
            }

            let selectedTitlesString = self.selectedSettingTitles!.joined(separator:", ")
            Mixpanel.mainInstance().people.set(properties: ["Study Spots Count": self.selectedSettingTitles?.count ?? 0])
            Mixpanel.mainInstance().people.set(properties: ["Study Spots": selectedTitlesString])
            
            settings = try? DataController.shared.getSettingsByTypeSelector(fromGroup: settingsGroup)

        } else if (settingsGroup.tag == "diet") {
            print("hello")
            let selectedSettings = (try? DataController.shared.getSettingsBySelectedTypeModifier(fromGroup: settingsGroup)) ?? [Setting]()

            for setting in selectedSettings {
                self.selectedSettingTitles?.append(setting.displayVal?[0] ?? "")
            }

            let selectedTitlesString = self.selectedSettingTitles!.joined(separator:", ")
            Mixpanel.mainInstance().people.set(properties: ["Diet": selectedTitlesString])
            
            settings = try? DataController.shared.getSettingsByTypeModifier(fromGroup: settingsGroup)
        }

        
        
        if settings?.count ?? 0 > 0 {
            self.settings = settings!
            self.displaySettings()
        } else {
            self.showAlert(message: nil, title: "Error, you have no cards!", completionHandler: {_ in })
        }
    }
    
    @IBAction func goBackPressed(_ sender: Any) {
        DispatchQueue.main.async {
            self.dismissKeyboardSearch(searchController: self.searchController)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        DispatchQueue.main.async {
            self.dismissKeyboardSearch(searchController: self.searchController)
            self.delegate?.settingsChanged()
            self.dismiss(animated: true, completion: nil)
        }
    }

    
    func displaySettings() {
        self.settingsMultiSelectTableView.reloadData()
//        self.settingsMultiSelectTableView.reloadSections([0], with: UITableView.RowAnimation.none)
        guard let settingsGroup = self.settingsGroup else { return }
        if (settingsGroup.modifierHeader?[0] != "none") {
            self.modifierHeader.text = settingsGroup.modifierHeader?[0]
        }
    }

    
        
    func getImageWithColor(color: UIColor, size: CGSize) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        let path = UIBezierPath(roundedRect: rect, cornerRadius: size.height/2.0)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        path.fill()
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}

extension SettingsMultiSelectViewController: UITableViewDelegate, UITableViewDataSource {
    func updateSelected(index: Int, to value: Bool) {
        if (self.filteredSettings?.count != 0) {
            self.filteredSettings?[index].selected = value

            guard let mainIndex = self.settings!.firstIndex(where: { (setting) -> Bool in
                setting.displayVal?[0] == self.filteredSettings?[index].displayVal?[0]
            }) else { return }
            self.settings?[mainIndex].selected = value

            try? DataController.shared.updateSettingSelected(setting: self.filteredSettings?[index] ?? Setting(context: DataController.shared.context), selected: value)
        } else {
            self.settings?[index].selected = value
            try? DataController.shared.updateSettingSelected(setting: self.settings?[index] ?? Setting(context: DataController.shared.context), selected: value)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.searchController.isActive && self.searchController.searchBar.text != "" {
            return self.filteredSettings?.count ?? 0
        }
        return self.settings?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.settingsMultiSelectTableView.dequeueReusableCell(withIdentifier: "SettingsMultiSelectTableViewCell", for: indexPath as IndexPath) as! SettingsMultiSelectTableViewCell
        
        if (self.filteredSettings?.count != 0) {
            cell.title.text = self.filteredSettings?[indexPath.row].displayVal?[0]
            if (self.filteredSettings?[indexPath.row].selected ?? false) {
                cell.checkBox.image = #imageLiteral(resourceName: "checkbox_selected")
            } else {
                cell.checkBox.image = #imageLiteral(resourceName: "checkbox")
            }
            
            return cell
        }

                        
        cell.title.text = self.settings?[indexPath.row].displayVal?[0]
        if (self.settings?[indexPath.row].selected ?? false) {
            cell.checkBox.image = #imageLiteral(resourceName: "checkbox_selected")
        } else {
            cell.checkBox.image = #imageLiteral(resourceName: "checkbox")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 73
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // selected the row
        if (!self.optionsChanged) {
            self.optionsChanged = true
            UIView.animate(withDuration: 0.8, delay: 0.0, options: .curveEaseInOut, animations: {
                self.cancelButton.isHidden = true
                self.doneButtonBackgroundView.isHidden = false
                self.settingsMultiSelectTableView.frame = CGRect(x: self.settingsMultiSelectTableView.frame.minX, y: self.settingsMultiSelectTableView.frame.minY, width: self.settingsMultiSelectTableView.frame.width, height: self.settingsMultiSelectTableView.frame.height - self.doneButtonBackgroundView.frame.height)
            }, completion: nil)
        }
        
        guard let cell = self.settingsMultiSelectTableView.cellForRow(at: IndexPath(row: indexPath.row, section: 0)) as? SettingsMultiSelectTableViewCell else { return }
        guard let cellTitle = cell.title.text else { return }

        if (self.selectedSettingTitles?.contains(cellTitle) ?? false) {
            if (self.settingsGroup?.tag != "diet") {
                if (self.selectedSettingTitles?.count ?? 0 <= 1) { return }
            }

            self.selectedSettingTitles = self.selectedSettingTitles?.filter { $0 != cell.title.text }
            self.updateSelected(index: indexPath.row, to: false)

            DispatchQueue.main.async {
                UIView.transition(with: cell.checkBox, duration: 0.2, options: .transitionCrossDissolve, animations: {
                    cell.checkBox.image = #imageLiteral(resourceName: "checkbox")
                })
            }
        } else {
            self.selectedSettingTitles?.append(cellTitle)
            self.updateSelected(index: indexPath.row, to: true)
            
            DispatchQueue.main.async {
                UIView.transition(with: cell.checkBox, duration: 0.2, options: .transitionCrossDissolve, animations: {
                    cell.checkBox.image = #imageLiteral(resourceName: "checkbox_selected")
                })
            }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.dismissKeyboardSearch(searchController: self.searchController)
    }
}

extension SettingsMultiSelectViewController: UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate {
    
    func filterSettings(searchText: String) {
        self.filteredSettings = self.settings?.filter { setting in
            let title = setting.displayVal?[0]
            let title_filtered = title?.folding(options: .diacriticInsensitive, locale: .current)
            return(title_filtered?.lowercased().contains(searchText.lowercased()))!
        }

        DispatchQueue.main.async {
            self.settingsMultiSelectTableView.reloadData()
        }
    }

    func updateSearchResults(for searchController: UISearchController) {
        guard let searchBarText = searchController.searchBar.text else { return }
        self.filterSettings(searchText: searchBarText)
    }

    func didPresentSearchController(_ searchController: UISearchController) {
        DispatchQueue.main.async {
            self.isSeachBarAnimationCompleted = true
            searchController.searchBar.becomeFirstResponder()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        guard self.isSeachBarAnimationCompleted else { return }
        self.isSeachBarAnimationCompleted = false
    }
}
