//
//  AccordionCardCollectionViewCell.swift
//  Iris
//
//  Created by Shalin Shah on 1/23/20.
//  Copyright © 2020 Shalin Shah. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import Alamofire
import CoreLocation
import Kingfisher
import SpotifyLogin

struct AccordionCellData {
    var opened = true
    var detail: Detail? = Detail(context: DataController.shared.context)
    var subdetails: [Subdetail]? = [Subdetail]()
}

protocol AccordionCardCollectionViewCellDelegate: class {
    func updateSentence(response: Response)
    func addAnimation()
    func removeAnimation()
    func cardRefreshed()
    func cardRefreshing()
}


class AccordionCardCollectionViewCell: UICollectionViewCell {
    
    var cardID: String!
    var currentDetailIndex: Int! = 0
    var responseID: String! = ""
    
    var response: Response?
    var details: [Detail]? = [Detail]()
    var subdetails: [[Subdetail]]? = [[Subdetail]]()

    var accordionTableData = [AccordionCellData]()

    weak var delegate: AccordionCardCollectionViewCellDelegate?
    
    var errorScreen: ErrorView!
    var errorShown: Bool! = false
    
    // Data Stuff
    var cardData: Extension_CardData? = Extension_CardData()
            
    // Subdetail Properties and UI Stuff
    @IBOutlet weak var detailTableView: UITableView! {
        didSet {
            self.detailTableView.estimatedRowHeight = 158
            self.detailTableView.rowHeight = UITableView.automaticDimension
            self.detailTableView.contentInset = UIEdgeInsets(top: 25,left: 0,bottom: 35,right: 0)
            self.detailTableView.delegate = self
            self.detailTableView.dataSource = self
            self.detailTableView.layer.shouldRasterize = true
            self.detailTableView.layer.rasterizationScale = UIScreen.main.scale
        }
    }

    func displayData(response: Response, settingsChanged: Bool) {
        let myGroup = DispatchGroup()
        myGroup.enter()

        self.response = response
        guard let localDetails = try? DataController.shared.getDetails(fromResponse: self.response?.responseID ?? "") else {
            self.delegate?.cardRefreshed()
            return
        }
        self.details = localDetails
        
        for detail in self.details ?? [Detail]() {
            myGroup.enter()
            guard let localSubdetails = try? DataController.shared.getSubdetails(fromDetailID: detail.detailID ?? "") else {
                self.delegate?.cardRefreshed()
                return
            }
            self.subdetails?.append(localSubdetails)
            self.accordionTableData.append(AccordionCellData(opened: false, detail: detail, subdetails: localSubdetails))
            myGroup.leave()
        }
        myGroup.leave()

        myGroup.notify(queue: .main) {
            DispatchQueue.main.async {
                if self.accordionTableData.first?.detail?.richLabel?["url"]?.lowercased().contains("no data") ?? false  {
                    if (settingsChanged) { self.errorShown = false }
                    if (!self.errorShown) {
                        self.displayNetworkError(type: .noContent)
                        self.errorShown = true
                    }
                } else {
                    if (self.errorShown) {
                        self.removeNetworkError(error: self.errorScreen)
                    }
                    self.errorShown = false
                }

                UIView.performWithoutAnimation {
                    self.detailTableView.reloadData()
                    self.detailTableView.beginUpdates()
                    self.detailTableView.endUpdates()
                }
                self.refreshTopBar()
                self.delegate?.removeAnimation()
            }
        }
    }

    
    func refreshAuthToken(success: @escaping (Bool) -> Void) {
        if let card = try? DataController.shared.getCard(fromID: self.cardID) {
            if (card.usesSpotify) {
                SpotifyLogin.shared.getAccessToken { (accessToken, error) in
                    if error != nil {
                        success(false)
                    } else {
                        print("Access Token Changed")
                        guard let user = try? DataController.shared.getUser(fromID: Auth.auth().currentUser?.uid ?? "") else { return }
                        try? DataController.shared.updateUserSpotifyToken(user: user, spotifyToken: accessToken ?? "")
                        success(true)
                    }
                }
            } else {
                success(false)
            }
        }
    }
    
    func refreshTopBar() {
        self.delegate?.updateSentence(response: self.response ?? Response(context: DataController.shared.context))
        self.delegate?.cardRefreshed()
    }
    
    func clearEverything() {
        self.details?.removeAll()
        self.subdetails?.removeAll()
        self.accordionTableData.removeAll()
        self.detailTableView.reloadData()
    }

    func refreshSequence(settingsChanged: Bool = false) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            if (settingsChanged) { self.clearEverything() }
            self.refreshAuthToken() { _ in
                self.cardData?.checkCacheForData(settingsChanged: settingsChanged, cardID: self.cardID)
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }
        
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.cardData?.delegate = self
                
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }

}

extension AccordionCardCollectionViewCell: Extension_CardDataDelegate {
    func startedRefreshing() {
        self.delegate?.cardRefreshing()
    }

    func finishedRefreshing() {
        self.delegate?.cardRefreshed()
    }
    
    func displayNetworkError(type: ErrorType) {
        self.errorScreen = self.addNetworkError(vc: self, type: type)
    }
    
    func removeNetworkError() {
        self.removeNetworkError(error: self.errorScreen)
    }

    func displayEverything(response: Response, settingsChanged: Bool) {
        self.displayData(response: response, settingsChanged: settingsChanged)
    }
    
    func startAnimation() {
        self.delegate?.addAnimation()
    }
    
    func endAnimation() {
        self.delegate?.removeAnimation()
    }
}

extension AccordionCardCollectionViewCell: ErrorViewDelegate {
    func tryAgainPushed() {
        guard let user = try? DataController.shared.getUser(fromID: Auth.auth().currentUser?.uid ?? "") else { return }
        try? DataController.shared.updateUserResponseRefreshIDs(user: user, responseRefreshIDs: ["none"])
        self.refreshSequence(settingsChanged: true)
    }
}


extension AccordionCardCollectionViewCell: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.accordionTableData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.accordionTableData[section].opened) {
            return (self.accordionTableData[section].subdetails?.count ?? 0) + 1
        }
        return 1
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            // DRAWER
            guard let detail = self.accordionTableData[indexPath.section].detail else { return UITableViewCell() }
            
            if detail.richLabel?["image"] != "none" {
                // RICH W/ IMAGE
                guard let cell = self.detailTableView.dequeueReusableCell(withIdentifier: "AccordionDrawerRichImageTableViewCell", for: indexPath as IndexPath) as? AccordionDrawerRichImageTableViewCell else { return UITableViewCell() }
                cell.arrowIcon.isHidden = (detail.richLabel?["url"]?.lowercased().contains("no data") ?? false) ? true : false
                cell.detailImage.kf.setImage(with: URL(string: (detail.richLabel?["image"])!))
                
                if (detail.richLabel?["icon"] == "none") {
                    cell.detailTitle.text = detail.richLabel?["text"]
                } else {
                    let time = UIImage.getImage(detail.richLabel?["icon"] ?? "none", sideLength: 20.0, color: UIColor.ColorTheme.Gray.Silver)
                    cell.detailTitle.addIconToLabel(image: time, text: detail.richLabel?["text"] ?? "none", imageOffsetY: -5.0)
                }
                
                if (detail.richSmallLabelOne?["icon"] == "none") {
                    if (detail.richSmallLabelOne?["text"] == "none") {
                        cell.detailSmallLabelOne.text = ""
                    } else {
                        cell.detailSmallLabelOne.text = detail.richSmallLabelOne?["text"]
                    }
                 } else {
                    let icon = UIImage.getImage(detail.richSmallLabelOne?["icon"] ?? "none", sideLength: 20.0, color: UIColor.ColorTheme.Gray.Silver)
                    cell.detailSmallLabelOne.addIconToLabel(image: icon, text: detail.richSmallLabelOne?["text"] ?? "none", imageOffsetY: -5.0)
                }
                
                if (detail.richSmallLabelTwo?["icon"] == "none") {
                    if (detail.richSmallLabelTwo?["text"] == "none") {
                        cell.detailSmallLabelTwo.text = ""
                    } else {
                        cell.detailSmallLabelTwo.text = detail.richSmallLabelTwo?["text"]
                    }
                } else {
                    if (detail.richSmallLabelTwo?["text"] == "none") {
                        cell.detailSmallLabelTwo.text = ""
                    } else {
                        let icon = UIImage.getImage(detail.richSmallLabelTwo?["icon"] ?? "none", sideLength: 20.0, color: UIColor.ColorTheme.Gray.Silver)
                        cell.detailSmallLabelTwo.addIconToLabel(image: icon, text: detail.richSmallLabelTwo?["text"] ?? "none", imageOffsetY: -5.0)
                    }
                }
                return cell
            }
            
            if detail.richSmallLabelOne?["text"] != "none" {
                // RICH
                guard let cell = self.detailTableView.dequeueReusableCell(withIdentifier: "AccordionDrawerRichTableViewCell", for: indexPath as IndexPath) as? AccordionDrawerRichTableViewCell else { return UITableViewCell() }
                cell.arrowIcon.isHidden = (detail.richLabel?["url"]?.lowercased().contains("no data") ?? false) ? true : false
                if (detail.richLabel?["icon"] == "none") {
                    cell.detailTitle.text = detail.richLabel?["text"]
                } else {
                    let time = UIImage.getImage(detail.richLabel?["icon"] ?? "none", sideLength: 20.0, color: UIColor.ColorTheme.Gray.Silver)
                    cell.detailTitle.addIconToLabel(image: time, text: detail.richLabel?["text"] ?? "none", imageOffsetY: -5.0)
                }
                
                if (detail.richSmallLabelOne?["icon"] == "none") {
                    if (detail.richSmallLabelOne?["text"] == "none") {
                        cell.detailSmallLabelOne.text = ""
                    } else {
                        cell.detailSmallLabelOne.text = detail.richSmallLabelOne?["text"]
                    }
                 } else {
                    let icon = UIImage.getImage(detail.richSmallLabelOne?["icon"] ?? "none", sideLength: 20.0, color: UIColor.ColorTheme.Gray.Silver)
                    cell.detailSmallLabelOne.addIconToLabel(image: icon, text: detail.richSmallLabelOne?["text"] ?? "none", imageOffsetY: -5.0)
                }
                
                if (detail.richSmallLabelTwo?["icon"] == "none") {
                    if (detail.richSmallLabelTwo?["text"] == "none") {
                        cell.detailSmallLabelTwo.text = ""
                    } else {
                        cell.detailSmallLabelTwo.text = detail.richSmallLabelTwo?["text"]
                    }
                } else {
                    if (detail.richSmallLabelTwo?["text"] == "none") {
                        cell.detailSmallLabelTwo.text = ""
                    } else {
                        let icon = UIImage.getImage(detail.richSmallLabelTwo?["icon"] ?? "none", sideLength: 20.0, color: UIColor.ColorTheme.Gray.Silver)
                        cell.detailSmallLabelTwo.addIconToLabel(image: icon, text: detail.richSmallLabelTwo?["text"] ?? "none", imageOffsetY: -5.0)
                    }
                }
                return cell
            }
            
            // SIMPLE
            guard let cell = self.detailTableView.dequeueReusableCell(withIdentifier: "AccordionDrawerSimpleTableViewCell", for: indexPath as IndexPath) as? AccordionDrawerSimpleTableViewCell else { return UITableViewCell() }
            cell.arrowIcon.isHidden = (detail.richLabel?["url"]?.lowercased().contains("no data") ?? false) ? true : false
            if (detail.richLabel?["icon"] == "none") {
                cell.detailTitle.text = (detail.richLabel?["text"]?.lowercased() != "no deals nearby") ? detail.richLabel?["text"] : ""
            } else {
                let time = UIImage.getImage(detail.richLabel?["icon"] ?? "none", sideLength: 20.0, color: UIColor.ColorTheme.Gray.Silver)
                cell.detailTitle.addIconToLabel(image: time, text: detail.richLabel?["text"] ?? "none", imageOffsetY: -5.0)
            }
            return cell
            
        } else {
            guard let subdetail = self.accordionTableData[indexPath.section].subdetails?[indexPath.row - 1] else { return UITableViewCell() }
            
            if subdetail.richLabel?["image"] ?? "none" != "none" {
                // REFRESH
                guard let cell = self.detailTableView.dequeueReusableCell(withIdentifier: "AccordionItemsRefreshTableViewCell", for: indexPath as IndexPath) as? AccordionItemsRefreshTableViewCell else { return UITableViewCell() }
                
                cell.detailImage.kf.setImage(with: URL(string: (subdetail.richLabel?["image"] ?? "none")))
                
                if (subdetail.richLabel?["icon"] == "none") {
                    cell.detailTitle.text = subdetail.richLabel?["text"] ?? "none"
                } else {
                    let time = UIImage.getImage(subdetail.richLabel?["icon"] ?? "none", sideLength: 20.0, color: UIColor.ColorTheme.Gray.Silver)
                    cell.detailTitle.addIconToLabel(image: time, text: subdetail.richLabel?["text"] ?? "none", imageOffsetY: -5.0)
                }
                
                if (subdetail.richSmallLabelOne?["icon"] == "none") {
                    if (subdetail.richSmallLabelOne?["text"] == "none") {
                        cell.detailSmallLabelOne.text = ""
                    } else {
                        cell.detailSmallLabelOne.text = subdetail.richSmallLabelOne?["text"]
                    }
                 } else {
                    let icon = UIImage.getImage(subdetail.richSmallLabelOne?["icon"] ?? "none", sideLength: 20.0, color: UIColor.ColorTheme.Gray.Silver)
                    cell.detailSmallLabelOne.addIconToLabel(image: icon, text: subdetail.richSmallLabelOne?["text"] ?? "none", imageOffsetY: -5.0)
                }
                
                if (subdetail.richSmallLabelTwo?["icon"] == "none") {
                    if (subdetail.richSmallLabelTwo?["text"] == "none") {
                        cell.detailSmallLabelTwo.text = ""
                    } else {
                        cell.detailSmallLabelTwo.text = subdetail.richSmallLabelTwo?["text"]
                    }
                } else {
                    if (subdetail.richSmallLabelTwo?["text"] == "none") {
                        cell.detailSmallLabelTwo.text = ""
                    } else {
                        let icon = UIImage.getImage(subdetail.richSmallLabelTwo?["icon"] ?? "none", sideLength: 20.0, color: UIColor.ColorTheme.Gray.Silver)
                        cell.detailSmallLabelTwo.addIconToLabel(image: icon, text: subdetail.richSmallLabelTwo?["text"] ?? "none", imageOffsetY: -5.0)
                    }
                }
                
                cell.refreshButton.addTarget(self, action: #selector(refreshButtonPressed(_:)), for: .touchUpInside)
                cell.refreshButton.row = indexPath.row
                cell.refreshButton.section = indexPath.section

                
                return cell
            }
            
            if subdetail.richSmallLabelOne?["text"] != "none" {
                // SELECTABLE
                
                guard let cell = self.detailTableView.dequeueReusableCell(withIdentifier: "AccordionItemsSelectableTableViewCell", for: indexPath as IndexPath) as? AccordionItemsSelectableTableViewCell else { return UITableViewCell() }
                
                if (subdetail.richLabel?["icon"] == "none") {
                    cell.detailTitle.text = subdetail.richLabel?["text"]
                } else {
                    let time = UIImage.getImage(subdetail.richLabel?["icon"] ?? "none", sideLength: 20.0, color: UIColor.ColorTheme.Gray.Silver)
                    cell.detailTitle.addIconToLabel(image: time, text: subdetail.richLabel?["text"] ?? "none", imageOffsetY: -5.0)
                }
                
                if (subdetail.selected) {
                    cell.checkBox.image = #imageLiteral(resourceName: "checkbox_selected")
                } else {
                    cell.checkBox.image = #imageLiteral(resourceName: "checkbox")
                }
                
                return cell
            }
            
            if subdetail.richLabel?["text"] != "none" {
                // SIMPLE W/ TITLE
                
                guard let cell = self.detailTableView.dequeueReusableCell(withIdentifier: "AccordionItemsSimpleTitleTableViewCell", for: indexPath as IndexPath) as? AccordionItemsSimpleTitleTableViewCell else { return UITableViewCell() }
                            
                let height = ("\t" + (subdetail.richDescription?["text"] ?? "none")).height(withConstrainedWidth: UIScreen.main.bounds.size.width - 44, font: UIFont(name: "NunitoSans-SemiBold", size: 14) ?? UIFont())
                cell.bgView.frame = CGRect(x: 22, y: 8, width: UIScreen.main.bounds.size.width - 44, height: height + 67)
                cell.detailDescription.frame = CGRect(x: 32, y: 45.33, width: UIScreen.main.bounds.size.width - 64, height: height + 21)

                
                if (subdetail.richDescription?["icon"] == "none") {
                    cell.detailDescription.text = subdetail.richDescription?["text"]
                } else {
                    let time = UIImage.getImage(subdetail.richDescription?["icon"] ?? "none", sideLength: 20.0, color: UIColor.ColorTheme.Gray.Silver)
                    cell.detailDescription.addIconToLabel(image: time, text: subdetail.richDescription?["text"] ?? "none", imageOffsetY: -5.0)
                }
                
                if (subdetail.richLabel?["icon"] == "none") {
                    cell.detailTitle.text = subdetail.richLabel?["text"]
                } else {
                    let time = UIImage.getImage(subdetail.richLabel?["icon"] ?? "none", sideLength: 20.0, color: UIColor.ColorTheme.Gray.Silver)
                    cell.detailTitle.addIconToLabel(image: time, text: subdetail.richLabel?["text"] ?? "none", imageOffsetY: -5.0)
                }
                
                return cell
            }
            

            // SIMPLE
            
            guard let cell = self.detailTableView.dequeueReusableCell(withIdentifier: "AccordionItemsSimpleTableViewCell", for: indexPath as IndexPath) as? AccordionItemsSimpleTableViewCell else { return UITableViewCell() }
                        
            let height = ("\t" + (subdetail.richDescription?["text"] ?? "none")).height(withConstrainedWidth: UIScreen.main.bounds.size.width - 44, font: UIFont(name: "NunitoSans-SemiBold", size: 14) ?? UIFont())
            cell.bgView.frame = CGRect(x: 22, y: 8, width: UIScreen.main.bounds.size.width - 44, height: height + 42)
            cell.detailDescription.frame = CGRect(x: 32, y: 17, width: UIScreen.main.bounds.size.width - 64, height: height + 21)
            
            
            if (subdetail.richDescription?["icon"] == "none") {
                cell.detailDescription.text = subdetail.richDescription?["text"]
            } else {
                let time = UIImage.getImage(subdetail.richDescription?["icon"] ?? "none", sideLength: 20.0, color: UIColor.ColorTheme.Gray.Silver)
                cell.detailDescription.addIconToLabel(image: time, text: subdetail.richDescription?["text"] ?? "none", imageOffsetY: -5.0)
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            guard let detail = self.accordionTableData[indexPath.section].detail else { return }
            if detail.richLabel?["url"]?.lowercased().contains("no data") ?? false { return }

            if self.accordionTableData[indexPath.section].opened {
                self.accordionTableData[indexPath.section].opened = false
                let sections = IndexSet(integer: indexPath.section)
                tableView.reloadSections(sections, with: .none)
            } else {
                self.accordionTableData[indexPath.section].opened = true
                let sections = IndexSet(integer: indexPath.section)
                tableView.reloadSections(sections, with: .none)
                tableView.scrollToRow(at: IndexPath(row: indexPath.row + 1, section: indexPath.section), at: .bottom, animated: true)
            }
            
            if detail.richLabel?["image"] != "none" {
                // RICH W/ IMAGE
                guard let cell = tableView.cellForRow(at: indexPath) as? AccordionDrawerRichImageTableViewCell else { return }
                if self.accordionTableData[indexPath.section].opened {
                    cell.arrowIcon.transform = CGAffineTransform(rotationAngle: .pi)
                } else {
                    cell.arrowIcon.transform =  CGAffineTransform.identity
                }
            } else if (detail.richSmallLabelOne?["text"] != "none") {
                // RICH
                guard let cell = tableView.cellForRow(at: indexPath) as? AccordionDrawerRichTableViewCell else { return }
                if self.accordionTableData[indexPath.section].opened {
                    cell.arrowIcon.transform = CGAffineTransform(rotationAngle: .pi)
                } else {
                    cell.arrowIcon.transform =  CGAffineTransform.identity
                }
            } else {
                // SIMPLE
                guard let cell = tableView.cellForRow(at: indexPath) as? AccordionDrawerSimpleTableViewCell else { return }
                if self.accordionTableData[indexPath.section].opened {
                    cell.arrowIcon.transform = CGAffineTransform(rotationAngle: .pi)
                } else {
                    cell.arrowIcon.transform =  CGAffineTransform.identity
                }
            }

        } else {
            if self.accordionTableData[indexPath.section].subdetails?[indexPath.row - 1].richDescription?["url"] != "none" {
                let url = URL(string: self.accordionTableData[indexPath.section].subdetails?[indexPath.row - 1].richDescription?["url"] ?? "none")!
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else if (self.accordionTableData[indexPath.section].subdetails?[indexPath.row - 1].richLabel?["url"] != "none") {
                let url = URL(string: self.accordionTableData[indexPath.section].subdetails?[indexPath.row - 1].richLabel?["url"] ?? "none")!
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else if self.accordionTableData[indexPath.section].subdetails?[indexPath.row - 1].richSmallLabelOne?["text"] != "none" {
                // SELECTABLE
                guard let cell = tableView.cellForRow(at: IndexPath(row: indexPath.row, section: indexPath.section)) as? AccordionItemsSelectableTableViewCell else { return }
                if (self.accordionTableData[indexPath.section].subdetails?[indexPath.row - 1].selected ?? false) {
                    try? DataController.shared.updateSubdetailSelected(subdetail: self.accordionTableData[indexPath.section].subdetails?[indexPath.row - 1] ?? Subdetail(context: DataController.shared.context), selected: false)
                    DispatchQueue.main.async {
                        UIView.transition(with: cell.checkBox, duration: 0.2, options: .transitionCrossDissolve, animations: {
                            cell.checkBox.image = #imageLiteral(resourceName: "checkbox")
                        })
                    }
                } else {
                    try? DataController.shared.updateSubdetailSelected(subdetail: self.accordionTableData[indexPath.section].subdetails?[indexPath.row - 1] ?? Subdetail(context: DataController.shared.context), selected: true)
                    DispatchQueue.main.async {
                        UIView.transition(with: cell.checkBox, duration: 0.2, options: .transitionCrossDissolve, animations: {
                            cell.checkBox.image = #imageLiteral(resourceName: "checkbox_selected")
                        })
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            guard let detail = self.accordionTableData[indexPath.section].detail else { return 0.0 }
            if detail.richLabel?["image"] != "none" {
                // RICH W/ IMAGE
                return 121
            } else if (detail.richSmallLabelOne?["text"] != "none") {
                // RICH
                return 101
            }
            // SIMPLE
            return 75
        }
        
        guard let subdetail = self.accordionTableData[indexPath.section].subdetails?[indexPath.row - 1] else { return 0.0 }
        if subdetail.richLabel?["image"] != "none" {
            // REFRESH
            return 140
        } else if subdetail.richSmallLabelOne?["text"] != "none" {
            // SELECTABLE
            return 68
        } else if subdetail.richLabel?["text"] != "none" {
            // SIMPLE W/ TITLE
            let title = (subdetail.richDescription?["text"] ?? "none")
            let height = ("\t" + title).height(withConstrainedWidth: UIScreen.main.bounds.size.width - 44, font: UIFont(name: "NunitoSans-SemiBold", size: 14) ?? UIFont()) + 83
            return height
        }
        
        // SIMPLE
        let title = (subdetail.richDescription?["text"] ?? "none")
        let height = ("\t" + title).height(withConstrainedWidth: UIScreen.main.bounds.size.width - 44, font: UIFont(name: "NunitoSans-SemiBold", size: 14) ?? UIFont()) + 57
        return height
        
    }
    
    @objc func refreshButtonPressed(_ sender: ButtonWithRowAndSection) {
        let row = sender.row!
        let section = sender.section!
        var recipeIDs = [String]()
        
        let myGroup = DispatchGroup()
        
        for subdetail in subdetails?[section] ?? [Subdetail]() {
            myGroup.enter()
            if subdetail.richSublabel?["text"] != self.accordionTableData[section].subdetails?[row - 1].richSublabel?["text"] {
                recipeIDs.append(subdetail.richSublabel?["text"] ?? "")
            }
            myGroup.leave()
        }
        
        myGroup.notify(queue: .main) {
            guard let user = try? DataController.shared.getUser(fromID: Auth.auth().currentUser?.uid ?? "") else { return }
            try? DataController.shared.updateUserResponseRefreshIDs(user: user, responseRefreshIDs: recipeIDs)
            self.refreshSequence(settingsChanged: true)
        }
        
    }
}


extension AccordionCardCollectionViewCell: ChoicesViewControllerDelegate {
    func newSettingSelected() {
        guard let user = try? DataController.shared.getUser(fromID: Auth.auth().currentUser?.uid ?? "") else { return }
        try? DataController.shared.updateUserResponseRefreshIDs(user: user, responseRefreshIDs: ["none"])
        self.refreshSequence(settingsChanged: true)
    }
}
