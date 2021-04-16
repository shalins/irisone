//
//  DataController.swift
//  Iris
//
//  Created by Shalin Shah on 1/15/20.
//  Copyright © 2020 Shalin Shah. All rights reserved.
//

import Foundation
import CoreData
import Alamofire
import FirebaseFirestore
import CoreLocation
import SwiftyJSON

class DataController {
    
    static let shared = DataController()
    private init() {
        self.initalizeStack(completion: {})
    }

    
    let persistentContainer = NSPersistentContainer(name: "Model")
    
    var context: NSManagedObjectContext {
        return self.persistentContainer.viewContext
    }
    
    func initalizeStack(completion: @escaping () -> Void) {
        //self.setStore(type: NSInMemoryStoreType)
        self.persistentContainer.loadPersistentStores { description, error in
            if let error = error {
                print("could not load store \(error.localizedDescription)")
                return
            }
            print("core data loaded")
            completion()
        }
    }

    // User stuff
    func createNewUser(fromUserProfile userProfile: UserProfiles?) throws {
        let user = User(context: self.context)
        user.userID = userProfile?.userID
        user.timeJoined = userProfile?.timeJoined as! Double
        user.fullName = userProfile?.fullName
        user.firstName = userProfile?.firstName
        user.lastName = userProfile?.lastName
        user.phoneNum = userProfile?.phoneNum
        user.pushToken = userProfile?.pushToken
        user.location = [UserLocation.latitude, UserLocation.longitude]
        user.oldResponseID = "none"
        user.spotify = "none"
        user.responseRefreshIDs = ["none"]

        self.context.insert(user)
        try self.context.save()
    }
    
    func updateUserLocation(user: User, lat: Double, lon: Double) throws {
        user.setValue([lat, lon], forKey: "location")
        try self.context.save()
    }
    
    func updateUserResponseID(user: User, responseID: String) throws {
        user.setValue(responseID, forKey: "oldResponseID")
        try self.context.save()
    }
    
    func updateUserResponseRefreshIDs(user: User, responseRefreshIDs: [String]) throws {
        user.setValue(responseRefreshIDs, forKey: "responseRefreshIDs")
        try self.context.save()
    }
    
    func updateUserSpotifyToken(user: User, spotifyToken: String) throws {
        user.setValue(spotifyToken, forKey: "spotify")
        try self.context.save()
    }


    
    func getUser(fromID id: String) throws -> User? {
        let request = NSFetchRequest<User>(entityName: "User")
        request.predicate = NSPredicate(format: "userID == %@", id)
        
        let users = try self.context.fetch(request)
        
        return users.last
    }
    
    
    // Add a card to that User's Profile
    func createNewCard(fromGlobalCard globalCard: GlobalCards?) throws -> Card? {
        let card = Card(context: self.context)
        
        let uuid = NSUUID().uuidString
        card.cardID = uuid
        card.globalCardID = globalCard?.cardID
        card.cardName = globalCard?.cardName
        card.icon = globalCard?.icon
        card.cardCategory = globalCard?.cardCategory
        card.cardDescription = globalCard?.cardDescription
        card.createdInLat = globalCard?.createdInLat as! Double
        card.createdInLon = globalCard?.createdInLon as! Double
        card.createdInLocation = globalCard?.createdInLocation
        card.tags = globalCard?.tags
        card.usesCurrentLocation = globalCard?.usesCurrentLocation ?? false
        card.usesSpotify = globalCard?.usesSpotify ?? false
        card.mapData = globalCard?.mapData ?? false
        card.accordionData = globalCard?.accordionData ?? false
        card.tableData = globalCard?.tableData ?? false
        card.refreshRadius = globalCard?.refreshRadius as? Double ?? 0.0
        card.refreshTime = globalCard?.refreshTime as? Double ?? 0.0
        card.version = Int16(globalCard?.version ?? 0)
        card.settingsGroupIDs = globalCard?.settingsGroupIDs

        card.lastLocationLat = UserLocation.latitude
        card.lastLocationLon = UserLocation.longitude
        card.lastTimestamp = Date().timeIntervalSince1970
        card.orderNumber = 0

        self.context.insert(card)
        try self.context.save()
        
        return card
    }
        
    // Add card to user profile
    func addCardToUser(user: User, card: Card) throws {
        user.addToCards(card)
        try self.context.save()
    }
    
    // Delete setting from a settings group
    func deleteCardFromUser(card: Card) throws {
        self.context.delete(card)
        try self.context.save()
    }

    
    func getCards(fromUser user: User?) throws -> [Card]? {
        
        let request = NSFetchRequest<Card>(entityName: "Card")
        request.sortDescriptors = [NSSortDescriptor(key: "orderNumber", ascending: true)]
        request.predicate = NSPredicate(format: "ANY %K =[cd] %@", #keyPath(Card.users.userID), user?.userID ?? "")
        
        let cards = try self.context.fetch(request)
        
        return cards
    }
    
    func getCard(fromID id: String) throws -> Card? {
        
        let request = NSFetchRequest<Card>(entityName: "Card")
        request.predicate = NSPredicate(format: "cardID == %@", id)
        
        let cards = try self.context.fetch(request)
        
        return cards.first
    }
    
    func updateCardLastLocation(card: Card, location: CLLocation) throws {
        card.setValue(location.coordinate.latitude, forKey: "lastLocationLat")
        card.setValue(location.coordinate.longitude, forKey: "lastLocationLon")
        try self.context.save()
    }
    
    func updateCardLastTimestamp(card: Card, timestamp: Double) throws {
        card.setValue(timestamp, forKey: "lastTimestamp")
        try self.context.save()
    }
    
    func updateCardOrderNumber(card: Card, orderNumber: Int) throws {
        card.setValue(orderNumber, forKey: "orderNumber")
        try self.context.save()
    }

    
    // Add all the Setting groups for that card
    func createNewSettingGroup(fromGlobalSettingGroup globalSettingGroup: SettingsGroup?) throws -> Setting_Group? {
        let settingGroup = Setting_Group(context: self.context)
        
        let uuid = NSUUID().uuidString
        settingGroup.settingsGroupID = uuid
        settingGroup.globalSettingsGroupID = globalSettingGroup?.settingsGroupID
        settingGroup.tag = globalSettingGroup?.tag
        settingGroup.selectorFormat = globalSettingGroup?.selectorFormat
        settingGroup.selectorEditable = globalSettingGroup?.selectorEditable ?? false
        settingGroup.selectorRemovable = globalSettingGroup?.selectorRemovable ?? false
        settingGroup.selectorHeader = globalSettingGroup?.selectorHeader
        settingGroup.modifierFormat = globalSettingGroup?.modifierFormat
        settingGroup.modifierEditable = globalSettingGroup?.modifierEditable ?? false
        settingGroup.modifierRemovable = globalSettingGroup?.modifierRemovable ?? false
        settingGroup.modifierHeader = globalSettingGroup?.modifierHeader

        self.context.insert(settingGroup)
        try self.context.save()
        
        return settingGroup
    }
    
    // Add settings group to card
    func addSettingsGroupToCard(card: Card, settingsGroup: Setting_Group) throws {
        card.addToSettings_groups(settingsGroup)
        try self.context.save()
    }
    
    func getSettingsGroups(fromCard card: Card) throws -> [Setting_Group]? {
        
        let request = NSFetchRequest<Setting_Group>(entityName: "Setting_Group")
        request.predicate = NSPredicate(format: "ANY %K =[cd] %@", #keyPath(Setting_Group.cards.cardID), card.cardID!)
        
        let settingsGroups = try self.context.fetch(request)
        
        return settingsGroups
    }
    
    func getSettingsGroup(fromID settingsGroupID: String) throws -> Setting_Group? {
        
        let request = NSFetchRequest<Setting_Group>(entityName: "Setting_Group")
        request.predicate = NSPredicate(format: "settingsGroupID == %@", settingsGroupID)
        
        let settingsGroup = try self.context.fetch(request)
        
        return settingsGroup.first
    }
    
    func getSettingsGroup(fromGlobalID globalSettingsGroupID: String) throws -> Setting_Group? {
        
        let request = NSFetchRequest<Setting_Group>(entityName: "Setting_Group")
        request.predicate = NSPredicate(format: "globalSettingsGroupID == %@", globalSettingsGroupID)
        
        let settingsGroup = try self.context.fetch(request)
        
        return settingsGroup.first
    }


    

        
    // Add all the Settings for that setting group
    func createNewSettings(fromGlobalSetting globalSetting: Settings?) throws -> Setting? {
        let setting = Setting(context: self.context)
        
        let uuid = NSUUID().uuidString
        setting.settingsID = uuid
        setting.displayVal = globalSetting?.displayVal
        setting.selected = globalSetting?.selected ?? false
        setting.type = globalSetting?.type
        setting.location = globalSetting?.location

        self.context.insert(setting)
        try self.context.save()
                
        return setting
    }
    
    // Add setting to a settings group
    func addSettingtoSettingsGroup(settingsGroup: Setting_Group, setting: Setting) throws {
        settingsGroup.addToSettings(setting)
        try self.context.save()
    }
    
    func updateSettingName(setting: Setting, newValue: [String]?) throws {
        setting.setValue(newValue, forKey: "displayVal")
        try self.context.save()
    }
    
    func updateSettingSelected(setting: Setting, selected: Bool? = false) throws {
        setting.setValue(selected, forKey: "selected")
        try self.context.save()
    }

    
    // Delete setting from a settings group
    func deleteSettingfromSettingsGroup(setting: Setting) throws {
        self.context.delete(setting)
        try self.context.save()
    }
    
    func sorterForTitlesAlphaNumeric(this : Setting?, that: Setting?) -> Bool {
        return this?.displayVal?.first ?? "a" < that?.displayVal?.first ?? "b"
    }
    
    func getSettings(fromGroup group: Setting_Group?) throws -> [Setting]? {
        let request = NSFetchRequest<Setting>(entityName: "Setting")
        request.predicate = NSPredicate(format: "ANY %K =[cd] %@", #keyPath(Setting.settings_groups.settingsGroupID), group?.settingsGroupID ?? "")
        let settings = try self.context.fetch(request)
        
        return settings.sorted(by: self.sorterForTitlesAlphaNumeric)
    }
    
    func getSettingsBySelected(fromGroup group: Setting_Group?) throws -> [Setting]? {
        let request = NSFetchRequest<Setting>(entityName: "Setting")
        request.predicate = NSPredicate(format: "ANY %K =[cd] %@ AND selected == true", #keyPath(Setting.settings_groups.settingsGroupID), group?.settingsGroupID ?? "")
        let settings = try self.context.fetch(request)
        
        return settings.sorted(by: self.sorterForTitlesAlphaNumeric)
    }
    
    func getSettingsByTypeSelector(fromGroup group: Setting_Group?) throws -> [Setting]? {
        let request = NSFetchRequest<Setting>(entityName: "Setting")
        request.predicate = NSPredicate(format: "ANY %K =[cd] %@ AND type == %@", #keyPath(Setting.settings_groups.settingsGroupID), group?.settingsGroupID ?? "", "selector")
        let settings = try self.context.fetch(request)
        
        return settings.sorted(by: self.sorterForTitlesAlphaNumeric)
    }
    
    func getSettingsBySelectedTypeModifier(fromGroup group: Setting_Group?) throws -> [Setting]? {
        let request = NSFetchRequest<Setting>(entityName: "Setting")
        request.predicate = NSPredicate(format: "ANY %K =[cd] %@ AND selected == true AND type == %@", #keyPath(Setting.settings_groups.settingsGroupID), group?.settingsGroupID ?? "", "modifier")
        let settings = try self.context.fetch(request)
        
        return settings.sorted(by: self.sorterForTitlesAlphaNumeric)
    }

    
    func getSettingsByTypeModifier(fromGroup group: Setting_Group?) throws -> [Setting]? {
        let request = NSFetchRequest<Setting>(entityName: "Setting")
        request.predicate = NSPredicate(format: "ANY %K =[cd] %@ AND type == %@", #keyPath(Setting.settings_groups.settingsGroupID), group?.settingsGroupID ?? "", "modifier")
        let settings = try self.context.fetch(request)
        
        return settings.sorted(by: self.sorterForTitlesAlphaNumeric)
    }

    
    
    
    
    
    
    
    
    func installCard(forUserWithID userID: String, fromGlobalCard globalCard: GlobalCards, orderNumber: Int, newCard: @escaping (Card) -> Void) {
        let currentCard = globalCard
        // create the card in Core Data the user's core data stack
        let card = try? DataController.shared.createNewCard(fromGlobalCard: currentCard)
        let user = try? DataController.shared.getUser(fromID: userID)
        try? DataController.shared.addCardToUser(user: user!, card: card!)
        
        DispatchQueue.main.async {
            try? DataController.shared.updateCardOrderNumber(card: card!, orderNumber: orderNumber)
        }

        // now fetch all the settings groups this card has
        var cardSettingsGroups = [SettingsGroup]()
        SettingsManager.fetchAllSettingsGroups(db: Firestore.firestore(), globalCard: currentCard, response: { response in
            if response?[0].tag != "" {
                cardSettingsGroups = response ?? [SettingsGroup]()
                
                // now save all these settings groups and then add them to the card
                for (i, settingsGroup) in cardSettingsGroups.enumerated() {
                    
                    // check if the shared setting group already exists
                    if let localGroup = try? DataController.shared.getSettingsGroup(fromGlobalID: settingsGroup.settingsGroupID ?? "") {
                        print("Setting Being Reused")
                        try? DataController.shared.addSettingsGroupToCard(card: card!, settingsGroup: localGroup)
                        if (i == cardSettingsGroups.count-1) {
                            newCard(card!)
                            return
                        } else {
                            continue
                        }
                    }
                    
                    let settingGroup = try? DataController.shared.createNewSettingGroup(fromGlobalSettingGroup: settingsGroup)
                    try? DataController.shared.addSettingsGroupToCard(card: card!, settingsGroup: settingGroup!)

                    // now for all the settings groups, go through all the settings
                    var cardSettings = [Settings]()
                    SettingsManager.fetchAllSettings(db: Firestore.firestore(), globalCard: currentCard, settingsGroup: settingsGroup, response: { response in
                        if response?[0].settingsID != "" {
                            cardSettings = response ?? [Settings]()
                            
                            let myGroup = DispatchGroup()
                            
                            // now save all these settings and then add them to the card
                            for settings in cardSettings {
                                myGroup.enter()
                                let setting = try? DataController.shared.createNewSettings(fromGlobalSetting: settings)
                                try? DataController.shared.addSettingtoSettingsGroup(settingsGroup: settingGroup!, setting: setting!)
                                myGroup.leave()
                            }
                            myGroup.notify(queue: .main) {
                                newCard(card!)
                                return
                            }
                        } else {
                            newCard(Card(context: self.context))
                            return
                        }
                    })
                }
            } else {
                newCard(Card(context: self.context))
                return
            }
        })
    }

    
    func cancelAllDataRequests() {
        NetworkSession.shared.sessionManager?.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
            sessionDataTask.forEach { $0.cancel() }
            uploadData.forEach { $0.cancel() }
            downloadData.forEach { $0.cancel() }
        }
    }
    
    
    func refreshCardDataFromServer(forUser userID: String, withCardID cardID: String, responseID: @escaping (JSON) -> Void) {
        // this is where we would send the json object to the server
        var jsonFormat: [String: Any]  = ["packet" : "none"]
        var jsonArray: [Data] = [Data]()
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .withoutEscapingSlashes
        
        let myGroup = DispatchGroup()
        myGroup.enter()
        
        let user = try? self.getUser(fromID: userID)
        do {
            let jsonData = try jsonEncoder.encode(user)
            jsonArray.append(jsonData)
        } catch {
            print("Error fetching data from CoreData")
        }
        
        let card = try? self.getCard(fromID: cardID)
        do {
            let jsonData = try jsonEncoder.encode(card)
            jsonArray.append(jsonData)
        } catch {
            print("Error fetching data from CoreData")
        }
        
        let settingsGroups = try? self.getSettingsGroups(fromCard: card!)
        for settingGroup in settingsGroups! {
            myGroup.enter()
            do {
                let jsonData = try jsonEncoder.encode(settingGroup)
                jsonArray.append(jsonData)
            } catch {
                print("Error fetching data from CoreData")
            }
            
            let settings = try? self.getSettingsBySelected(fromGroup: settingGroup)
            for setting in settings! {
                myGroup.enter()
                do {
                    let jsonData = try jsonEncoder.encode(setting)
                    jsonArray.append(jsonData)
                } catch {
                    print("Error fetching data from CoreData")
                }
                myGroup.leave()
            }
            myGroup.leave()
        }
        myGroup.leave()
        
        myGroup.notify(queue: .main) {
            let myGroup2 = DispatchGroup()
            myGroup2.enter()

            var jsonNewFormat: [Any] = [Any]()
            for i in 0..<jsonArray.count {
                myGroup2.enter()
                do {
                    let json = try JSONSerialization.jsonObject(with: jsonArray[i], options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any]
                    jsonNewFormat.append(json!)
                } catch {
                    print("error")
                }
                myGroup2.leave()
            }
            myGroup2.leave()

            myGroup2.notify(queue: .main) {
                jsonFormat["packet"] = jsonNewFormat

                let headers = ["Content-Type": "application/json"]
                NetworkSession.shared.sessionManager?.request("https://us-central1-iris-263608.cloudfunctions.net/http_card_manager_test", method: .post, parameters: jsonFormat, encoding: JSONEncoding.default, headers: headers).responseString { response in
                    if (response.result.isFailure) {
                        responseID(JSON("none"))
                    }
                    do {
                        if let data = response.result.value {
                            if let dataFromString = data.data(using: .utf8, allowLossyConversion: false) {
                                let json = try JSON(data: dataFromString)
                                responseID(json)
                            } else {
                                responseID(JSON("none"))
                            }
                        }
                    } catch {
                        responseID(JSON("none"))
                    }
                    debugPrint(response)
                }
            }
        }
    }
}
