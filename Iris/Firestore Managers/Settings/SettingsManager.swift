//
//  SettingsManager.swift
//  Iris
//
//  Created by Shalin Shah on 1/15/20.
//  Copyright © 2020 Shalin Shah. All rights reserved.
//

import Foundation
import FirebaseFirestore


struct SettingsManager {
    static func fetchAllSettingsGroups(db: Firestore, globalCard: GlobalCards, response: @escaping ([SettingsGroup]?) -> Void) {
        var cardSettingsGroups = [SettingsGroup]() // this is the data for each of the subdetails in the detail array
        
        let myGroup = DispatchGroup()
        guard let settingIDs = globalCard.settingsGroupIDs else { response([SettingsGroup()]); return }
        for settingID in settingIDs {
            myGroup.enter()
            db.collection("global_settings").document(settingID).getDocument() { (querySnapshot, err) in
                myGroup.leave()
                if let document = querySnapshot, let data = document.data() {
                    let setting = SettingsGroup(settingsGroupIDString: data["settings_group_id"] as? String, tagString: data["tag"] as? String, selectorFormatString: data["selector_format"] as? String, selectorEditableBool: data["selector_editable"] as? Bool, selectorRemovableBool: data["selector_removable"] as? Bool, selectorHeaderArray: data["selector_header"] as? [String], modifierFormatString: data["modifier_format"] as? String, modifierEditableBool: data["modifier_editable"] as? Bool, modifierRemovableBool: data["modifier_removable"] as? Bool, modifierHeaderArray: data["modifier_header"] as? [String])
                    cardSettingsGroups.append(setting)
                } else {
                    print("Document does not exist")
                    response([SettingsGroup()])
                    return
                }
            }
        }
                
        myGroup.notify(queue: .main) {
            response(cardSettingsGroups)
            return
        }
    }
    
    static func fetchAllSettings(db: Firestore, globalCard: GlobalCards, settingsGroup: SettingsGroup, response: @escaping ([Settings]?) -> Void) {

        var cardSettings = [Settings]() // this is the data for each of the subdetails in the detail array
        
        let myGroup = DispatchGroup()
        myGroup.enter()
        guard let settingID = settingsGroup.settingsGroupID else { response([Settings()]); return }
        db.collection("global_settings").document(settingID).collection("settings").getDocuments() { (querySnapshot, err) in
            myGroup.leave()
            if let _ = err {
                response([Settings()])
                return
            } else {
                guard let documents = querySnapshot?.documents else { response([Settings()]); return }
                for document in documents {
                    // we're looping through the different Card Details to get the Subdetails ex: looping through the different bus stops (details) to get the different bus times (subdetails)
                    myGroup.enter()
                    
                    let data = document.data()
                    let setting = Settings(settingsIDString: data["settings_id"] as? String, displayValArray: data["display_val"] as? [String], selectedBool: data["selected"] as? Bool, typeString: data["type"] as? String, locationArray: data["location"] as? [String])
                    cardSettings.append(setting)
                    
                    myGroup.leave()
                }
            }
        }

        myGroup.notify(queue: .main) {
            response(cardSettings)
            return
        }
    }
}
