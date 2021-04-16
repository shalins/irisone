//
//  Extension_CardData.swift
//  Iris
//
//  Created by Shalin Shah on 2/1/20.
//  Copyright © 2020 Shalin Shah. All rights reserved.
//

import UIKit
import CoreLocation
import FirebaseAuth
import SwiftyJSON
import Mixpanel

protocol Extension_CardDataDelegate: class {
    func startAnimation()
    func endAnimation()
    func displayNetworkError(type: ErrorType)
    func removeNetworkError()
    func displayEverything(response: Response, settingsChanged: Bool)
    func finishedRefreshing()
    func startedRefreshing()
}

class Extension_CardData: UICollectionViewCell {
    
    weak var delegate: Extension_CardDataDelegate?
    var cardID: String!
    var alreadyDisplayingFirstError: Bool! = false
    var alreadyDisplayingSecondError: Bool! = false
    var refreshing: Bool! = false
    var settingsChanged: Bool! = false
    
    func isSettingOutdated(currentCard: Card?) -> Bool {
        if (currentCard?.mapData ?? false) {
            var settingsGroup: Setting_Group?
            guard let settingsGroups: [Setting_Group] = try? DataController.shared.getSettingsGroups(fromCard: currentCard ?? Card(context: DataController.shared.context)) else { return false }

            for group in settingsGroups {
                if group.tag == "common_locations" { settingsGroup = group; break }
            }
            
            let settings = try? DataController.shared.getSettingsByTypeSelector(fromGroup: settingsGroup)
            if settings?.count ?? 0 > 1 {
                guard let selectedSetting = try? DataController.shared.getSettingsBySelected(fromGroup: settingsGroup)?.first else { return false }

                let distanceInMeters = CLLocation(latitude: CLLocationDegrees(selectedSetting.location?[1] ?? "0") ?? CLLocationDegrees(0), longitude: CLLocationDegrees(selectedSetting.location?[2] ?? "0") ?? CLLocationDegrees(0)).distance(from: UserLocation.userlocation) // result is in meters
                if distanceInMeters < 241.5 {
                    for set in settings ?? [Setting]() {
                        if (set.selected == false) {
                            try? DataController.shared.updateSettingSelected(setting: set, selected: true)
                            try? DataController.shared.updateSettingSelected(setting: selectedSetting, selected: false)
                            return true
                        }
                    }
                }
                return false
            }
            return false
        }
        return false
    }

    func isDataOutdated(settingsChanged: Bool, currentCard: Card?) -> Bool {
        let difference = Date().timeIntervalSince1970 - currentCard!.lastTimestamp
        let distanceInMeters = CLLocation(latitude: currentCard!.lastLocationLat, longitude: currentCard!.lastLocationLon).distance(from: UserLocation.userlocation) // result is in meters
        
        if (!settingsChanged) { if (isSettingOutdated(currentCard: currentCard)) { return true } }
        if currentCard!.refreshTime != 0 {
            if difference >= currentCard!.refreshTime { return true }
        }
        if currentCard!.refreshRadius != 0 {
            if distanceInMeters >= currentCard!.refreshRadius { return true }
        }
        if settingsChanged { return true }
        
        return false
    }

    func checkCacheForData(settingsChanged: Bool, cardID: String) {
        self.cardID = cardID
        self.settingsChanged = settingsChanged
        self.cancelCurrentAllRequests()
        
        let currentCard = try? DataController.shared.getCard(fromID: cardID)
        Mixpanel.mainInstance().track(event: (currentCard?.cardName ?? "") + " Card Loaded")
        Mixpanel.mainInstance().people.increment(property: (currentCard?.cardName ?? "") + " Card Load Count", by: 1)

        // check if the response data already exists
        if let localResponse = try? DataController.shared.getResponse(fromCardID: cardID) {
            if (!isDataOutdated(settingsChanged: settingsChanged, currentCard: currentCard)) {
                // reload everything with the current data
                print("checking cache 1")
                self.delegate?.displayEverything(response: localResponse, settingsChanged: self.settingsChanged)
            } else {
                print("checking cache 2")
                self.refreshData(cardID: cardID)
            }
        } else {
            print("checking cache 3")
            self.refreshData(cardID: cardID)
        }
    }
    
    
    // step 1: check if we're connected to the internet
    func checkInternet(connected:@escaping (Bool) -> Void) {
        if Reachability.isConnectedToNetwork() {
            self.alreadyDisplayingFirstError = false
            self.delegate?.removeNetworkError()
            self.delegate?.endAnimation()
            connected(true)
        } else {
            if (!self.alreadyDisplayingFirstError) {
                self.alreadyDisplayingFirstError = true
                self.delegate?.displayNetworkError(type: .noInternet)

                self.delegate?.finishedRefreshing()
                self.delegate?.startAnimation()
            }
            connected(false)
        }
    }
    
    func startedRefreshingData() {
        self.delegate?.startAnimation()
        self.delegate?.startedRefreshing()
        self.refreshing = true
    }
    
    func finishedRefreshingData() {
        self.delegate?.finishedRefreshing()
        self.delegate?.endAnimation()
        self.refreshing = false
    }
    
    func refreshData(settingsChanged: Bool = false, cardID: String) {
        self.checkInternet() { connected in
            if connected {
                if (!self.refreshing) {
                    self.startedRefreshingData()
                    
                    let user = try? DataController.shared.getUser(fromID: Auth.auth().currentUser!.uid)
                    DataController.shared.refreshCardDataFromServer(forUser: user?.userID ?? "", withCardID: cardID, responseID: { response in
                        if (response == "none") {
                            if (!self.alreadyDisplayingSecondError) {
                                self.alreadyDisplayingSecondError = true
                                self.delegate?.displayNetworkError(type: .interalServer)
                            }
                            self.finishedRefreshingData()
                        } else {
                            try? DataController.shared.updateUserResponseID(user: user!, responseID: response["response"]["response_id"].stringValue)
                            self.updateLastUserData(cardID: cardID)
                            self.installData(cardID: cardID, response: response)
                        }
                    })
                }
            }
        }
    }

    func installData(cardID: String, response: JSON) {
        print("cardID ", cardID)
        DataController.shared.installDataFromJSON(cardID: cardID, responseJSON: response, newResponse: { response in
            DispatchQueue.main.async {
                self.finishedRefreshingData()
                self.delegate?.removeNetworkError()
                self.alreadyDisplayingSecondError = false
                self.delegate?.displayEverything(response: response ?? Response(context: DataController.shared.context), settingsChanged: self.settingsChanged)
            }
        })
    }
    
    func updateLastUserData(cardID: String) {
        guard let currentCard = try? DataController.shared.getCard(fromID: cardID) else { return }
        try? DataController.shared.updateCardLastLocation(card: currentCard, location: CLLocation(latitude: UserLocation.latitude, longitude: UserLocation.longitude))
        try? DataController.shared.updateCardLastTimestamp(card: currentCard, timestamp: Date().timeIntervalSince1970)
    }
    
    func cancelCurrentAllRequests() {
        DataController.shared.cancelAllDataRequests()
    }
}
