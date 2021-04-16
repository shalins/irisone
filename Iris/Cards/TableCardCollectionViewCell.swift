//
//  TableCardCollectionViewCell.swift
//  Iris
//
//  Created by Shalin Shah on 1/22/20.
//  Copyright © 2020 Shalin Shah. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import Alamofire
import CoreLocation

protocol TableCardCollectionViewCellDelegate: class {
    func updateSentence(response: Response)
    func addAnimation()
    func removeAnimation()
    func cardRefreshed()
    func cardRefreshing()
}

class TableCardCollectionViewCell: UICollectionViewCell {
    
    // Logic Stuff
    var cardID: String!
    var currentDetailIndex: Int! = 0
    var responseID: String! = ""

    var response: Response?
    var details: [Detail]? = [Detail]()
    var subdetails: [[Subdetail]]? = [[Subdetail]]()
    
    var errorScreen: ErrorView!
    var animation: TableLoadingHUD!

    weak var delegate: TableCardCollectionViewCellDelegate?
    
    // Data Stuff
    var cardData: Extension_CardData? = Extension_CardData()
            
    // Subdetail Properties and UI Stuff
    @IBOutlet weak var detailTableView: UITableView! {
        didSet {
            self.detailTableView.estimatedRowHeight = 185
            self.detailTableView.rowHeight = UITableView.automaticDimension
            self.detailTableView.delegate = self
            self.detailTableView.dataSource = self
            self.detailTableView.contentInset = UIEdgeInsets(top: 60,left: 0,bottom: 35,right: 0)
            self.detailTableView.layer.shouldRasterize = true
            self.detailTableView.layer.rasterizationScale = UIScreen.main.scale
        }
    }
    
    @IBOutlet weak var liveLabel: UILabel! {
        didSet {
            self.liveLabel.layer.shouldRasterize = true
            self.liveLabel.layer.rasterizationScale = UIScreen.main.scale
        }
    }
    
    @IBOutlet weak var liveLabelDot: UIView! {
        didSet {
            self.liveLabelDot.makeCorner(withRadius: self.liveLabelDot.frame.height / 2)
            self.liveLabelDot.layer.shouldRasterize = true
            self.liveLabelDot.layer.rasterizationScale = UIScreen.main.scale
        }
    }
    
    @IBOutlet weak var liveLabelBG: UIView! {
        didSet {
            self.liveLabelBG.makeCorner(withRadius: 8)
            self.liveLabelBG.layer.shouldRasterize = true
            self.liveLabelBG.layer.rasterizationScale = UIScreen.main.scale
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
            guard let localSubdetails = try? DataController.shared.getSubdetails(fromDetailID: detail.detailID!) else {
                self.delegate?.cardRefreshed()
                return
            }
            self.subdetails?.append(localSubdetails)
            myGroup.leave()
        }
        myGroup.leave()

        myGroup.notify(queue: .main) {
            DispatchQueue.main.async {
                if (self.subdetails?.first?.first?.richDescription?["text"]?.contains("none") ?? false) {
                    self.liveLabelBG.isHidden = false
                    self.liveLabelDot.alpha = 1.0
                    UIView.animate(withDuration: 2.0, delay: 0.0, options: [.repeat,.autoreverse], animations: {
                        self.liveLabelDot.alpha = 0.0
                    }, completion: nil)
                } else {
                    self.liveLabelBG.isHidden = true
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
        
    func refreshTopBar() {
        self.delegate?.updateSentence(response: self.response ?? Response(context: DataController.shared.context))
        self.delegate?.cardRefreshed()
    }
    
    func clearEverything() {
        self.details?.removeAll()
        self.subdetails?.removeAll()
        self.detailTableView.reloadData()
    }

    func refreshSequence(settingsChanged: Bool = false) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            if (settingsChanged) { self.clearEverything() }
            self.cardData?.checkCacheForData(settingsChanged: settingsChanged, cardID: self.cardID)
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

extension TableCardCollectionViewCell: Extension_CardDataDelegate {
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
//        self.animation = self.addTableAnimation()
        self.delegate?.addAnimation()
    }
    
    func endAnimation() {
//        self.removeTableAnimation(loader: self.animation)
        self.delegate?.removeAnimation()
    }
}

extension TableCardCollectionViewCell: ErrorViewDelegate {
    func tryAgainPushed() {
        self.refreshSequence(settingsChanged: true)
    }
}


extension TableCardCollectionViewCell: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.details?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let subdetail = self.subdetails?[indexPath.row].first else { return UITableViewCell() }
        
        if (subdetail.richDescription?["text"]?.contains("none") ?? false) {
            let cell = self.detailTableView.dequeueReusableCell(withIdentifier: "DetailTableViewNormalCell", for: indexPath as IndexPath) as! DetailTableViewNormalCell
            
            if (subdetail.richLabel?["icon"] == "none") {
                cell.detailTitle.text = subdetail.richLabel?["text"]
            } else {
                let time = UIImage.getImage(subdetail.richLabel?["icon"] ?? "none", sideLength: 25.0, color: UIColor.white)
                cell.detailTitle.addIconToLabel(image: time, text: subdetail.richLabel?["text"] ?? "none", imageOffsetY: -5.0)
            }
            
            let height = ("\t" + (subdetail.richLabel?["text"] ?? "none")).height(withConstrainedWidth: UIScreen.main.bounds.size.width - 44, font: UIFont(name: "NunitoSans-Bold", size: 18) ?? UIFont())
            cell.bgView.frame = CGRect(x: 22, y: 8, width: UIScreen.main.bounds.size.width - 44, height: height + 87)
            cell.detailTitle.frame = CGRect(x: 32, y: 42, width: UIScreen.main.bounds.size.width - 64, height: height + 21)
            cell.detailSmallLabelTwo.frame = CGRect(x: 32, y: 48+height+14, width: UIScreen.main.bounds.size.width - 64, height: 20)
            
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
                let icon = UIImage.getImage(subdetail.richSmallLabelTwo?["icon"] ?? "none", sideLength: 20.0, color: UIColor.ColorTheme.Gray.Silver)
                cell.detailSmallLabelTwo.addIconToLabel(image: icon, text: subdetail.richSmallLabelTwo?["text"] ?? "none", imageOffsetY: -5.0)
            }
            
            return cell

        } else {
            let cell = self.detailTableView.dequeueReusableCell(withIdentifier: "DetailTableViewCell", for: indexPath as IndexPath) as! DetailTableViewCell

            if (subdetail.richDescription?["text"]?.lowercased().contains("closed") ?? false) {
                cell.bgView.backgroundColor = UIColor.ColorTheme.Blue.BlackRussian
                cell.percentage.isHidden = true
            } else {
                cell.bgView.backgroundColor = UIColor.black
                cell.percentage.isHidden = false
            }
            
            if (subdetail.richLabel?["icon"] == "none") {
                cell.detailTitle.text = subdetail.richLabel?["text"]
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
                if (subdetail.richSmallLabelTwo?["text"] == "!timestamp") {
                    cell.detailSmallLabelTwo.text = Date(timeIntervalSince1970: Double(truncating: NSNumber(value: subdetail.timestamp))).timestampString
                } else {
                    if (subdetail.richSmallLabelTwo?["text"] == "none") {
                        cell.detailSmallLabelTwo.text = ""
                    } else {
                        cell.detailSmallLabelTwo.text = subdetail.richSmallLabelTwo?["text"]
                    }
                }
            } else {
                let time = UIImage.getImage(subdetail.richSmallLabelTwo?["icon"] ?? "none", sideLength: 20.0, color: UIColor.ColorTheme.Gray.Silver)
                if (subdetail.richSmallLabelTwo?["text"] == "!timestamp") {
                    let timestamp = Date(timeIntervalSince1970: Double(truncating: NSNumber(value: subdetail.timestamp))).timestampString
                    cell.detailSmallLabelTwo.addIconToLabel(image: time, text: timestamp!, imageOffsetY: -5.0)
                } else {
                    if (subdetail.richSmallLabelTwo?["text"] == "none") {
                        cell.detailSmallLabelTwo.text = ""
                    } else {
                        cell.detailSmallLabelTwo.addIconToLabel(image: time, text: subdetail.richSmallLabelTwo?["text"] ?? "none", imageOffsetY: -5.0)
                    }
                }
            }
            let progressNum = (subdetail.richMetric?["text"] ?? "0").trimmingCharacters(in: CharacterSet(charactersIn: "0123456789.").inverted)
            cell.progressView.setProgress(percent: CGFloat(Float(progressNum) ?? 0))
            cell.percentage.text = String(Int(Float(progressNum)! * 100)) + "%"
            
            if (subdetail.richDescription?["icon"] == "none") {
                if (subdetail.richDescription?["text"] == "none") {
                    cell.detailDescription.text = ""
                } else {
                    if (subdetail.richDescription?["text"] == "none") {
                        cell.detailDescription.text = ""
                    } else {
                        cell.detailDescription.text = subdetail.richDescription?["text"]
                    }
                }
            } else {
                let time = UIImage.getImage(subdetail.richDescription?["icon"] ?? "none", sideLength: 20.0, color: UIColor.ColorTheme.Gray.Silver)
                cell.detailDescription.addIconToLabel(image: time, text: subdetail.richDescription?["text"] ?? "none", imageOffsetY: -5.0)
            }

            
            return cell

        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let subdetail = self.subdetails?[indexPath.row].first else { return }
        if (subdetail.richDescription?["text"]?.contains("none") ?? false) {
            if (subdetail.richLabel?["url"] != "none") {
                let url = URL(string: subdetail.richLabel?["url"] ?? "none")!
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let subdetail = self.subdetails?[indexPath.row].first else { return 0 }
        if (subdetail.richDescription?["text"]?.contains("none") ?? false) {
            let height = ("\t" + (subdetail.richLabel?["text"] ?? "none")).height(withConstrainedWidth: UIScreen.main.bounds.size.width - 44, font: UIFont(name: "NunitoSans-Bold", size: 18) ?? UIFont())
            return height + 105
        }
        return 185
    }
}


extension TableCardCollectionViewCell: SettingsMultiSelectViewControllerDelegate {
    func settingsChanged() {
        self.refreshSequence(settingsChanged: true)
    }
}
