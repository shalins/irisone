//
//  CardCollectionViewCell.swift
//  Iris
//
//  Created by Shalin Shah on 1/8/20.
//  Copyright © 2020 Shalin Shah. All rights reserved.
//

import UIKit
import MapKit
import FirebaseFirestore
import FirebaseAuth
import Mapbox
import Alamofire

protocol MapCardCollectionViewCellDelegate: class {
    func updateSentence(response: Response)
    func addAnimation()
    func removeAnimation()
    func cardRefreshed()
    func cardRefreshing()
    func sentenceSettingEdited(response: Response!, index: Int!, nickname: String!)
}

class MapCardCollectionViewCell: UICollectionViewCell {
        
    // Logic Stuff
    var cardID: String!
    var currentDetailIndex: Int! = 0
    var responseID: String! = ""
    
    var response: Response?
    var details: [Detail]? = [Detail]()
    var subdetails: [[Subdetail]]? = [[Subdetail]]()

    weak var delegate: MapCardCollectionViewCellDelegate?
    
    var busTimer: Timer?
    
    var errorScreen: ErrorView!
    
    // Data Stuff
    var cardData: Extension_CardData? = Extension_CardData()
    
    // Top Labels UI Stuff
    @IBOutlet weak var bottomView: CurvedUIView! {
        didSet {
            //self.bottomView.rotate(angle: 180)
            self.bottomView.layer.shouldRasterize = true
            self.bottomView.layer.rasterizationScale = UIScreen.main.scale
        }
    }
    
    @IBOutlet weak var draggableView: UIView! {
        didSet {
            self.draggableView.layer.shouldRasterize = true
            self.draggableView.layer.rasterizationScale = UIScreen.main.scale
        }
    }
    
    @IBOutlet weak var drawer: UIView! {
        didSet {
            self.drawer.makeCorner(withRadius: self.drawer.frame.height/2)
            self.drawer.layer.shouldRasterize = true
            self.drawer.layer.rasterizationScale = UIScreen.main.scale
        }
    }

    // Map View, Properties and UI Stuff
    var cardMap: CardMap = CardMap()
    var cardLoaded: Bool! = false
    var cardMapStyle: MGLStyle!
    @IBOutlet weak var mapView: MGLMapView! {
        didSet {
            self.mapView.setCenter(CLLocationCoordinate2D(latitude: 37.870456, longitude: -122.2540443), zoomLevel: 16, animated: false)

            self.mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            // Tint the ℹ️ button and the user location annotation.
            self.mapView.tintColor = UIColor.ColorTheme.Blue.Electric
            self.mapView.attributionButton.tintColor = .lightGray

            self.mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            self.mapView.showsUserLocation = true
            self.mapView.userTrackingMode = .followWithHeading
            
            self.mapView.showsUserHeadingIndicator = true
            self.mapView.compassView.isHidden = true
            self.mapView.logoView.isHidden = true
            self.mapView.attributionButton.isHidden = true
                        
            self.mapView.layer.shouldRasterize = true
            self.mapView.layer.rasterizationScale = UIScreen.main.scale
            
        }
    }
    
    func removeAllAnnotations(annotations: MGLAnnotation) {
        guard let annotations = self.mapView.annotations else { return print("No Annotations To Remove") }
        if annotations.count != 0 {
            for annotation in annotations {
                self.mapView.removeAnnotation(annotation)
            }
        } else {
            return
        }
    }
    
    @IBOutlet weak var userLocationButton: UIButton! {
        didSet {
            self.userLocationButton.layer.shouldRasterize = true
            self.userLocationButton.layer.rasterizationScale = UIScreen.main.scale
        }
    }
            
    // Subdetail Properties and UI Stuff
    @IBOutlet weak var detailTitle: UILabel! {
        didSet {
            self.detailTitle.layer.shouldRasterize = true
            self.detailTitle.layer.rasterizationScale = UIScreen.main.scale
        }
    }

    @IBOutlet weak var detailSmallLabelOne: UILabel! {
        didSet {
            self.detailSmallLabelOne.layer.shouldRasterize = true
            self.detailSmallLabelOne.layer.rasterizationScale = UIScreen.main.scale
        }
    }
    
    @IBOutlet weak var detailSmallLabelTwo: UILabel! {
        didSet {
            self.detailSmallLabelTwo.layer.shouldRasterize = true
            self.detailSmallLabelTwo.layer.rasterizationScale = UIScreen.main.scale
        }
    }
    
    @IBOutlet weak var detailMetric: UILabel! {
        didSet {
            self.detailMetric.layer.shouldRasterize = true
            self.detailMetric.layer.rasterizationScale = UIScreen.main.scale
        }
    }
    
    @IBOutlet weak var detailMetricUnits: UILabel! {
        didSet {
            self.detailMetric.layer.shouldRasterize = true
            self.detailMetric.layer.rasterizationScale = UIScreen.main.scale
        }
    }

    @IBOutlet weak var detailMetricTwo: UILabel! {
        didSet {
            self.detailMetric.layer.shouldRasterize = true
            self.detailMetric.layer.rasterizationScale = UIScreen.main.scale
        }
    }

    @IBOutlet weak var detailMetricUnitsTwo: UILabel! {
        didSet {
            self.detailMetric.layer.shouldRasterize = true
            self.detailMetric.layer.rasterizationScale = UIScreen.main.scale
        }
    }

    
    @IBOutlet weak var detailDescription: UILabel! {
        didSet {
            self.detailDescription.layer.shouldRasterize = true
            self.detailDescription.layer.rasterizationScale = UIScreen.main.scale
        }
    }
        

    func addAnnotation(from detail: Detail) {
        if (detail.richLabel?["text"] == "none") { return }
        let latitude = Double(truncating: NSNumber(value: detail.lat))
        let longitude = Double(truncating: NSNumber(value: detail.lon))

        let annotation = IrisAnnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        annotation.richLabel = detail.richLabel!
        annotation.richSmallLabelOne = detail.richSmallLabelOne!
        annotation.setMetadata(richLabel: detail.richLabel!)

        self.mapView.addAnnotation(annotation)
    }

    func displayData(response: Response, settingsChanged: Bool) {
        let myGroup = DispatchGroup()

        self.response = response
        guard let localDetails = try? DataController.shared.getDetails(fromResponse: self.response?.responseID ?? "") else {
            self.delegate?.cardRefreshed()
            return
        }
        self.details = localDetails
        
        if (self.details?.count == 1 && self.details?.first?.richLabel?["text"]?.lowercased().contains("destination") ?? false) {
            self.draggableView.isHidden = true
            self.moveDrawerDown()
        } else {
            self.draggableView.isHidden = false
            self.moveDrawerUp()
        }

        for detail in self.details ?? [Detail]() {
            myGroup.enter()

            self.addAnnotation(from: detail)
            
            guard let localSubdetails = try? DataController.shared.getSubdetails(fromDetailID: detail.detailID!) else {
                self.delegate?.cardRefreshed()
                return
            }
            self.subdetails?.append(localSubdetails)
            myGroup.leave()
        }

        myGroup.notify(queue: .main) {
            DispatchQueue.main.async {
                self.displaySubdetails()
                self.refreshTopBar()
                if (self.cardLoaded) {
                    self.setupResponseGeojsonURL(response: self.response)
                }
                self.delegate?.removeAnimation()
            }
        }
    }
    
    func setupResponseGeojsonURL(response: Response?) {
        guard let response = response else { return }
        self.cardMap.geoJSONURL = response.responseURL
        
        for detail in self.details ?? [Detail]() {
            if (detail.richLabel?["text"]?.lowercased().contains("destination") ?? false) {
                self.cardMap.destination = CLLocationCoordinate2D(latitude: detail.lat, longitude: detail.lon)
            }
        }
        
        if (response.responseURLType == "heatmap") {
            self.cardMap.mapType = .heatmap
            self.cardMap.drawHeatmap(mapView: self.mapView, style: self.cardMapStyle)
        } else if (response.responseURLType == "route") {
            self.cardMap.mapType = .route
            self.cardMap.drawPolyline(mapView: self.mapView)
        }
    }
    
    func displaySubdetails(selectedLatitude: CLLocationDegrees = 0.0) {
        self.currentDetailIndex = selectedLatitude != 0.0 ? self.getIndexOfSelectedDetail(selectedLatitude: selectedLatitude) : 0
        
        for (index, detail) in self.details?.enumerated() ?? ([Detail]()).enumerated() {
            if (detail.richLabel?["text"] == "none") {
                self.currentDetailIndex = index
            }
        }
        
        if (self.details?.count ?? 0 > self.currentDetailIndex ?? 0) {
            if self.details?[self.currentDetailIndex].richLabel?["text"]?.lowercased().contains("destination") ?? false {
                self.currentDetailIndex = self.currentDetailIndex == 0 ? (self.details?.count ?? 1) - 1 : 0
            }
        }

        if self.subdetails?.count ?? 0 < self.currentDetailIndex + 1 { return }
        guard let subdetail = self.subdetails?[self.currentDetailIndex].first else { return }

        if (subdetail.richLabel?["icon"] == "none") {
            if (subdetail.richLabel?["text"] == "none") {
                self.detailTitle.text = ""
            } else {
                self.detailTitle.text = subdetail.richLabel?["text"]
            }
        } else {
            let time = UIImage.getImage(subdetail.richLabel?["icon"] ?? "none", sideLength: 20.0, color: UIColor.ColorTheme.Gray.Silver)
            self.detailTitle.addIconToLabel(image: time, text: subdetail.richLabel?["text"] ?? "none", imageOffsetY: -5.0)
        }
        
        if (subdetail.richSmallLabelOne?["icon"] == "none") {
            if (subdetail.richSmallLabelOne?["text"] == "none") {
                self.detailSmallLabelOne.text = ""
            } else {
                self.detailSmallLabelOne.text = subdetail.richSmallLabelOne?["text"]
            }
         } else {
            if (subdetail.richSmallLabelOne?["icon"] == "severe" || subdetail.richSmallLabelOne?["icon"] == "moderate" || subdetail.richSmallLabelOne?["icon"] == "low") {
                let resourceName = (subdetail.richSmallLabelOne?["icon"] ?? "none") + "_icon"
                let severity = #imageLiteral(resourceName: resourceName)
                self.detailSmallLabelOne.textColor = UIColor.ColorTheme.Pink.BrinkPink
                self.detailSmallLabelOne.addIconToLabel(image: severity, text: subdetail.richSmallLabelOne?["text"] ?? "none", imageOffsetY: 2.0)
            } else {
                let time = UIImage.getImage(subdetail.richSmallLabelOne?["icon"] ?? "none", sideLength: 20.0, color: UIColor.ColorTheme.Gray.Silver)
                self.detailSmallLabelOne.textColor = UIColor.ColorTheme.Gray.Silver
                self.detailSmallLabelOne.addIconToLabel(image: time, text: subdetail.richSmallLabelOne?["text"] ?? "none", imageOffsetY: -5.0)
            }
        }
        if (subdetail.richSmallLabelTwo?["icon"] == "none") {
            if (subdetail.richSmallLabelTwo?["text"] == "!timestamp") {
                self.detailSmallLabelTwo.text = Date(timeIntervalSince1970: Double(truncating: NSNumber(value: subdetail.timestamp))).timestampString
            } else {
                if (subdetail.richSmallLabelTwo?["text"] == "none") {
                    self.detailSmallLabelTwo.text = ""
                } else {
                    self.detailSmallLabelTwo.text = subdetail.richSmallLabelTwo?["text"]
                }
            }
        } else {
            let time = UIImage.getImage(subdetail.richSmallLabelTwo?["icon"] ?? "none", sideLength: 20.0, color: UIColor.ColorTheme.Gray.Silver)
            if (subdetail.richSmallLabelTwo?["text"] == "!timestamp") {
                let timestamp = Date(timeIntervalSince1970: Double(truncating: NSNumber(value: subdetail.timestamp))).timestampString
                self.detailSmallLabelTwo.addIconToLabel(image: time, text: timestamp!, imageOffsetY: -5.0)
            } else {
                if (subdetail.richSmallLabelTwo?["text"] == "none") {
                    self.detailSmallLabelTwo.text = ""
                } else {
                    self.detailSmallLabelTwo.addIconToLabel(image: time, text: subdetail.richSmallLabelTwo?["text"] ?? "none", imageOffsetY: -5.0)
                }
            }
        }
        
        if (subdetail.richDescription?["icon"] == "none") {
            if (subdetail.richDescription?["text"] == "none") {
                self.detailDescription.text = ""
            } else {
                if (subdetail.richDescription?["text"] == "none") {
                    self.detailDescription.text = ""
                } else {
                    self.detailDescription.text = subdetail.richDescription?["text"]
                }
            }
        } else {
            let time = UIImage.getImage(subdetail.richDescription?["icon"] ?? "none", sideLength: 20.0, color: UIColor.ColorTheme.Gray.Silver)
            self.detailDescription.addIconToLabel(image: time, text: subdetail.richDescription?["text"] ?? "none", imageOffsetY: -5.0)
        }
        
        
        // the Rich Metric is basically only for the bus card and handles for
        if (subdetail.richMetric?["icon"] == "none") {
            if (subdetail.richMetric?["text"] == "none") {
                self.detailMetric.text = ""
            } else {
                self.detailMetric.text = subdetail.richMetric?["text"]
            }
        } else {
            let time = UIImage.getImage(subdetail.richMetric?["icon"] ?? "none", sideLength: 20.0, color: UIColor.ColorTheme.Gray.Silver)
            self.detailMetric.addIconToLabel(image: time, text: subdetail.richMetric?["text"] ?? "none", imageOffsetY: -5.0)
        }
        
        if (subdetail.richMetricUnits?["icon"] == "none") {
            if (subdetail.richMetricUnits?["text"] == "none") {
                self.detailMetricUnits.text = ""
            } else {
                self.detailMetricUnits.text = subdetail.richMetricUnits?["text"]
            }
        } else {
            let time = UIImage.getImage(subdetail.richMetricUnits?["icon"] ?? "none", sideLength: 20.0, color: UIColor.ColorTheme.Gray.Silver)
            self.detailMetricUnits.addIconToLabel(image: time, text: subdetail.richMetricUnits?["text"] ?? "none", imageOffsetY: -5.0)
        }
        
        self.getTimeUntil()
    }
    
    @objc func changeLabel() {
        // if user is not within the radius, keep showing the stuff you're showign now, else show pull cord information
        // 1) find the detail with "text" that says "last_stop"
        if self.subdetails?.count ?? 0 < self.currentDetailIndex + 1 { return }

        var lastStopDetail: Detail? = nil
        for detail in self.details ?? [Detail]() {
            if detail.richLabel?["text"] == "last_spot" { lastStopDetail = detail; break }
        }
        

        if lastStopDetail != nil {
            if (self.subdetails?[self.currentDetailIndex].count ?? 0 < 2) { return }
            guard let subdetail = self.subdetails?[self.currentDetailIndex][1] else { return }
            
            let distanceInMeters = CLLocation(latitude: lastStopDetail?.lat ?? 0, longitude: lastStopDetail?.lon ?? 0).distance(from: UserLocation.userlocation) // result is in meters

            if distanceInMeters <= (Double(subdetail.richMetricTwo?["value"] ?? "0") ?? 0) {
                // change rich label
                if (subdetail.richLabel?["icon"] == "none") {
                    if (subdetail.richLabel?["text"] == "none") {
                        self.detailTitle.text = ""
                    } else {
                        self.detailTitle.text = subdetail.richLabel?["text"]
                    }
                } else {
                    let time = UIImage.getImage(subdetail.richLabel?["icon"] ?? "none", sideLength: 20.0, color: UIColor.ColorTheme.Gray.Silver)
                    self.detailTitle.addIconToLabel(image: time, text: subdetail.richLabel?["text"] ?? "none", imageOffsetY: -5.0)
                }

                // change richMetric
                self.detailMetric.isHidden = true
                self.detailMetricUnits.isHidden = true
                return
            } else {
                self.detailMetric.isHidden = false
                self.detailMetricUnits.isHidden = false
            }
        }

        guard let subdetail = self.subdetails?[self.currentDetailIndex].first else { return }
        if (subdetail.richMetric?["value"] != "none") {
            let metricSeconds = (Double(subdetail.richMetric?["value"] ?? "0") ?? 0) - Date().timeIntervalSince1970
            let metricMinutes = max(metricSeconds / 60.0, 0)
            self.detailMetric.text = String(Int(metricMinutes))
            if (self.detailMetric.text == "1") { self.detailMetricUnits.text = "min" }
            if (self.detailMetric.text == "0") { self.detailMetricUnits.text = "min" }
        }
    }
    
    func getTimeUntil() {
        if self.busTimer == nil {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
//                UserLocation.userlocation = CLLocation(latitude: 37.8628126, longitude: -122.3172785)
//                UserLocation.latitude = 37.8628126
//                UserLocation.longitude = -122.3172785
//            }

            self.busTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(changeLabel), userInfo: nil, repeats: true)
        }
    }

    func centerMapOnUser() {
        mapView.userTrackingMode = .followWithHeading
    }
    
    @IBAction func locationButtonTapped(sender: UIButton) {
        mapView.userTrackingMode = .followWithHeading
    }
    
    @IBAction func uberButtonTapped(sender: UIButton) {
        var destination: Detail = Detail(context: DataController.shared.context)
        guard let details = self.details else { return }
        for detail in details {
            if (detail.richLabel?["text"]?.lowercased().contains("destination") ?? false) {
                destination = detail
            }
        }
//        let index = self.getIndexOfSelectedDetail(selectedLatitude: destination.lat)
        
        let uberURL = "uber://?client_id=KpcK98kmSchs6iGxgz39PIGbHoFmqf1u&action=setPickup&pickup[latitude]=" + String(UserLocation.latitude) + "&pickup[longitude]=" + String(UserLocation.longitude) //+ "&dropoff[nickname]=Current%20Location"
        let uberURL2 = uberURL + "&dropoff[latitude]=" + String(destination.lat) + "&dropoff[longitude]=" + String(destination.lon)
//        let uberURL3 = uberURL2 + "&dropoff[nickname]=" + (self.subdetails?[index].first?.richLabel?["text"] ?? "")
        let url = URL(string: uberURL2)!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    @IBAction func lyftButtonTapped(sender: UIButton) {
        var destination: Detail = Detail(context: DataController.shared.context)
        guard let details = self.details else { return }
        for detail in details {
            if (detail.richLabel?["text"]?.lowercased().contains("destination") ?? false) {
                destination = detail
            }
        }
        
        let lyftURL = "lyft://ridetype?id=lyft&partner=9xE2OpfQF9mh&pickup[latitude]=" + String(UserLocation.latitude) + "&pickup[longitude]=" + String(UserLocation.longitude)
        let lyftURL2 = lyftURL + "&destination[latitude]=" + String(destination.lat) + "&destination[longitude]=" + String(destination.lon)
        let url = URL(string: lyftURL2)!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    func getIndexOfSelectedDetail(selectedLatitude: CLLocationDegrees) -> Int {
        for i in 0...((self.details?.count ?? 0) - 1) {
            let detailLat = Double(truncating: NSNumber(value: self.details?[i].lat ?? 0.0))
            if detailLat == selectedLatitude {
                return i
            }
        }
        return 0
    }
     
    
    func refreshTopBar() {
        self.delegate?.updateSentence(response: self.response ?? Response(context: DataController.shared.context))
        self.delegate?.cardRefreshed()
    }
    
    func clearEverything() {
        self.detailTitle.text = ""
        self.detailSmallLabelOne.text = ""
        self.detailSmallLabelTwo.text = ""
        self.detailMetric.text = ""
        self.detailMetricUnits.text = ""
        self.detailMetricTwo.text = ""
        self.detailMetricUnitsTwo.text = ""
        self.detailDescription.text = ""
        self.cardMap.removeAllAnnotations(mapView: self.mapView, annotations: self.mapView.annotations)
        self.details?.removeAll()
        self.subdetails?.removeAll()
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
            
        self.mapView.delegate = cardMap
        self.cardMap.delegate = self
        self.cardData?.delegate = self
                                
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(wasDragged))
        self.draggableView.addGestureRecognizer(gesture)
        self.draggableView.isUserInteractionEnabled = true
        gesture.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appCameToForeground), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
    
    @objc func appMovedToBackground() {
        print("app enters background")
        if (self.busTimer != nil) {
            self.busTimer?.invalidate()
            self.busTimer = nil
        }
    }
    
    @objc func appCameToForeground() {
        print("app enters foreground")
        self.getTimeUntil()
    }
}



extension MapCardCollectionViewCell: Extension_CardDataDelegate {
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

extension MapCardCollectionViewCell: ErrorViewDelegate {
    func tryAgainPushed() {
        self.refreshSequence(settingsChanged: true)
    }
}


extension MapCardCollectionViewCell: UIGestureRecognizerDelegate {
    @objc func wasDragged(gestureRecognizer: UIPanGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizer.State.changed {
            let translation = gestureRecognizer.translation(in: self)
            print(gestureRecognizer.view!.center.y)
            if (gestureRecognizer.view!.center.y >= self.frame.size.height - (self.draggableView.frame.size.height/2)) {
                gestureRecognizer.view?.center = CGPoint(
                  x: gestureRecognizer.view!.center.x,
                  y: max(gestureRecognizer.view!.center.y + translation.y, self.frame.size.height - (self.draggableView.frame.size.height/2))
                )
            }
            gestureRecognizer.setTranslation(CGPoint(x: 0,y: 0), in: self)
        } else if gestureRecognizer.state == UIGestureRecognizer.State.ended {
              let velocity = gestureRecognizer.velocity(in: self)

              if velocity.y >= 1500 || self.draggableView.frame.origin.y > self.frame.size.height - 100 {
                self.moveDrawerDown()
              } else {
                self.moveDrawerUp()
              }
            }
        }
    
    func hideEverything() {
        self.detailTitle.alpha = 0.0
        self.detailSmallLabelOne.alpha = 0.0
        self.detailSmallLabelTwo.alpha = 0.0
        self.detailMetric.alpha = 0.0
        self.detailMetricUnits.alpha = 0.0
        self.detailMetricTwo.alpha = 0.0
        self.detailMetricUnitsTwo.alpha = 0.0
        self.detailDescription.alpha = 0.0
    }
    
    func showEverything() {
        self.detailTitle.alpha = 1.0
        self.detailSmallLabelOne.alpha = 1.0
        self.detailSmallLabelTwo.alpha = 1.0
        self.detailMetric.alpha = 1.0
        self.detailMetricUnits.alpha = 1.0
        self.detailMetricTwo.alpha = 1.0
        self.detailMetricUnitsTwo.alpha = 1.0
        self.detailDescription.alpha = 1.0
    }

    func moveDrawerDown() {
        UIView.animate(withDuration: 0.2
          , animations: {
            self.hideEverything()
            let bottomPoint = self.frame.size.height - 65
            self.draggableView.frame.origin = CGPoint(
              x: self.draggableView.frame.origin.x,
              y: bottomPoint
            )
            self.userLocationButton.frame.origin = CGPoint(x: self.userLocationButton.frame.origin.x, y: bottomPoint - (self.draggableView.frame.size.height/2 + 15))
          }, completion: nil)
    }
    
    func moveDrawerUp() {
        UIView.animate(withDuration: 0.2 , animations: {
            self.showEverything()
            self.draggableView.frame.origin = CGPoint(
                x: self.draggableView.frame.origin.x,
                y: self.frame.size.height - (self.draggableView.frame.size.height)
            )
            self.userLocationButton.frame.origin = CGPoint(x: self.userLocationButton.frame.origin.x, y: self.frame.size.height - (self.draggableView.frame.size.height) - (self.userLocationButton.frame.size.height) + 15)
        }, completion: nil)
    }
}

extension MapCardCollectionViewCell: CardSettingsViewControllerDelegate {
    func newSettingSelected() {
        self.refreshSequence(settingsChanged: true)
    }
    
    func settingNameEdited(index: Int!, nickname: String!) {
        self.delegate?.sentenceSettingEdited(response: self.response, index: index, nickname: nickname)
    }
}

extension MapCardCollectionViewCell: CardMapDelegate {
    func doneLoading(mapView: MGLMapView, didFinishLoading style: MGLStyle) {
        self.cardLoaded = true
        self.cardMapStyle = style
        self.centerMapOnUser()
    }
    
    func calloutViewTapped(mapView: MGLMapView, calloutViewFor annotation: MGLAnnotation) {
        if (annotation.title??.lowercased().contains("destination") ?? false) || (annotation.title??.lowercased().contains("you are here") ?? false) { return }
        self.moveDrawerUp()
        self.displaySubdetails(selectedLatitude: annotation.coordinate.latitude)
    }
}

