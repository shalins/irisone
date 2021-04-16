//
//  SettingsDetailViewController.swift
//  Iris
//
//  Created by Shalin Shah on 1/17/20.
//  Copyright © 2020 Shalin Shah. All rights reserved.
//

import UIKit
import MapKit

protocol SettingsDetailViewControllerDelegate: class {
    func addedNewPlace()
}

class SettingsDetailViewController: UIViewController {
    
    var settingsGroup: Setting_Group?
    
    var searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    var isSeachBarAnimationCompleted: Bool = false

    weak var delegate: SettingsDetailViewControllerDelegate?

    @IBOutlet weak var searchView: UIView! {
        didSet {
            self.searchView.layer.shouldRasterize = true
            self.searchView.layer.rasterizationScale = UIScreen.main.scale
        }
    }
    let searchController = UISearchController(searchResultsController: nil)


    
    @IBOutlet weak var settingsDetailTableView: UITableView! {
        didSet {
            self.settingsDetailTableView.delegate = self
            self.settingsDetailTableView.dataSource = self
            self.settingsDetailTableView.layer.shouldRasterize = true
            self.settingsDetailTableView.layer.rasterizationScale = UIScreen.main.scale
        }
    }
    
    @IBAction func goBackPressed(_ sender: Any) {
        DispatchQueue.main.async {
            self.dismissKeyboardSearch(searchController: self.searchController)
            self.dismiss(animated: true, completion: nil)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
                
        self.searchController.searchBar.placeholder = "Search for places"
        self.searchController.searchBar.searchBarStyle = .minimal
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.obscuresBackgroundDuringPresentation = false
        
        let image = self.getImageWithColor(color: UIColor.ColorTheme.Blue.Mirage, size: CGSize(width: 20, height: 49))
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
        placeholderAppearance.padding = UIEdgeInsets(top: 2, left: 25, bottom: 0, right: 0)
        placeholderAppearance.textColor = UIColor.ColorTheme.Gray.Silver

        self.definesPresentationContext = false
        self.searchView.addSubview(self.searchController.searchBar)
        
        self.searchController.delegate = self
        self.searchController.searchBar.delegate = self
        self.searchController.searchResultsUpdater = self
        
        searchCompleter.delegate = self
        searchCompleter.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: UserLocation.latitude, longitude: UserLocation.longitude), latitudinalMeters: 3000, longitudinalMeters: 3000)
        searchCompleter.resultTypes = [.address, .pointOfInterest]
        
        self.view.layer.shouldRasterize = true
        self.view.layer.rasterizationScale = UIScreen.main.scale
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.delay(0.1) {self.searchController.searchBar.becomeFirstResponder()}
    }
    
    deinit {
        self.searchController.searchResultsUpdater = nil
        self.searchController.searchBar.delegate = nil
        self.searchController.delegate = nil
    }
    
    func addNewSetting (title: String, address: String, latitude: Double, longitude: Double, type: String) {
        let displayValArray = [title, "none", "none", "none"]
        let locationArray = [address, String(latitude), String(longitude)]
        let newSetting = Settings(settingsIDString: "anything", displayValArray: displayValArray, selectedBool: false, typeString: type, locationArray: locationArray)
        
        let setting = try? DataController.shared.createNewSettings(fromGlobalSetting: newSetting)
        try? DataController.shared.addSettingtoSettingsGroup(settingsGroup: self.settingsGroup ?? Setting_Group(context: DataController.shared.context), setting: setting!)
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

extension SettingsDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func checkAddress() {
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.settingsDetailTableView.dequeueReusableCell(withIdentifier: "SettingsDetailTableViewCell", for: indexPath as IndexPath) as! SettingsDetailTableViewCell
        let searchResult = searchResults[indexPath.row]

        cell.title?.text = searchResult.title
        cell.subTitle?.text = searchResult.subtitle

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 73
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // selected the row
        guard let cell = self.settingsDetailTableView.cellForRow(at: IndexPath(row: indexPath.row, section: 0)) as? SettingsDetailTableViewCell else { return }
        guard let title = cell.title?.text else { return }
        
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = title + " " + (cell.subTitle?.text ?? "")
        print(title + " " + (cell.subTitle?.text ?? ""))
        searchRequest.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: UserLocation.latitude, longitude: UserLocation.longitude), latitudinalMeters: 3000, longitudinalMeters: 3000)
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            guard let response = response else {
                self.dismissKeyboardSearch(searchController: self.searchController)
                self.showAlert(message: nil, title: "Full address not found 1!", completionHandler: { _ in })
                return
            }
            
            var potentialCoordinate: CLLocationCoordinate2D? = nil
            for item in response.mapItems {
                if (cell.title.text?.contains(item.name ?? "") ?? false || item.name?.contains(cell.title?.text ?? "") ?? false) {
                    // this is a match!
                    potentialCoordinate = response.mapItems.first?.placemark.coordinate
                    break
                }
            }
            if potentialCoordinate == nil {
                // 2nd pass
                let searchRequest = MKLocalSearch.Request()
                searchRequest.naturalLanguageQuery = title
                print(title + " " + (cell.subTitle?.text ?? ""))
                searchRequest.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: UserLocation.latitude, longitude: UserLocation.longitude), latitudinalMeters: 3000, longitudinalMeters: 3000)
                let search = MKLocalSearch(request: searchRequest)
                search.start { response, error in
                    guard let response = response else {
                        self.dismissKeyboardSearch(searchController: self.searchController)
                        self.showAlert(message: nil, title: "Full address not found 2!", completionHandler: { _ in })
                        return
                    }
                    
                    for item in response.mapItems {
                        if (cell.title.text?.contains(item.name ?? "") ?? false || item.name?.contains(cell.title?.text ?? "") ?? false) {
                            // this is a match!
                            potentialCoordinate = response.mapItems.first?.placemark.coordinate
                            break
                        }
                    }
                    guard let coordinate = potentialCoordinate else {
                        self.dismissKeyboardSearch(searchController: self.searchController)
                        self.showAlert(message: nil, title: "Full address not found 3!", completionHandler: { _ in })
                        return
                    }
                    
                    self.addNewSetting(title: title, address: cell.subTitle.text ?? "", latitude: coordinate.latitude, longitude: coordinate.longitude, type: "selector")
                    self.delegate?.addedNewPlace()
                    
                    self.dismissKeyboardSearch(searchController: self.searchController)
                    self.dismiss(animated: true, completion: nil)
                }
            } else {
                guard let coordinate = potentialCoordinate else {
                    self.dismissKeyboardSearch(searchController: self.searchController)
                    self.showAlert(message: nil, title: "Full address not found 4!", completionHandler: { _ in })
                    return
                }
                self.addNewSetting(title: title, address: cell.subTitle.text ?? "", latitude: coordinate.latitude, longitude: coordinate.longitude, type: "selector")
                self.delegate?.addedNewPlace()
                
                self.dismissKeyboardSearch(searchController: self.searchController)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.dismissKeyboardSearch(searchController: self.searchController)
    }
}

extension SettingsDetailViewController: UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchBarText = searchController.searchBar.text else { return }
        searchCompleter.queryFragment = searchBarText
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

extension SettingsDetailViewController: MKLocalSearchCompleterDelegate {

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.searchResults = completer.results.filter { !$0.subtitle.lowercased().contains("search nearby") && $0.subtitle.lowercased().replacingOccurrences(of: "\\s", with: "", options: .regularExpression) != "" && ($0.subtitle.lowercased().contains("berkeley") || $0.subtitle.lowercased().contains("oakland") || $0.subtitle.lowercased().contains("emeryville") || $0.subtitle.lowercased().contains("albany") || $0.subtitle.lowercased().contains("piedmont")) }
        self.settingsDetailTableView.reloadData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {

    }
}

