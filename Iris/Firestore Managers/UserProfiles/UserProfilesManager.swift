//
//  UserProfilesManager.swift
//  Iris
//
//  Created by Shalin Shah on 1/7/20.
//  Copyright © 2020 Shalin Shah. All rights reserved.
//

import Foundation
import FirebaseFirestore

struct UserProfilesManager {

    
    // whenever we're writing a new anything, our parameters should contain the entire Class (in this case the class is UserProfiles)
    static func writeNewUser(db: Firestore, userProfiles: UserProfiles, success: @escaping (Bool) -> Void) {
        let userInfo = ["user_id": userProfiles.userID ?? "",
                        "phone_number": userProfiles.phoneNum ?? "",
                        "push_token": userProfiles.pushToken ?? "",
                        "time_joined": userProfiles.timeJoined ?? 0.0] as [String : Any]
        
        db.collection("user_profiles").document(userProfiles.userID ?? "").setData(userInfo)
        
        success(true)
    }
    
    // whenever we're fetching anything, we only want to pass the parameters that we're going to be using in the url that we need to fetch from
    static func fetchGlobalCards(db: Firestore, response: @escaping ([GlobalCards]?) -> Void) {
        var cardInformation = [GlobalCards]()
            
        let myGroup = DispatchGroup()
        myGroup.enter()
        db.collection("global_cards").order(by: "order_number", descending: false).getDocuments() { (querySnapshot, err) in
            myGroup.leave()
            if let _ = err {
                response([GlobalCards()])
                return
            } else {
                guard let documents = querySnapshot?.documents else { response([GlobalCards()]); return }
                for document in documents {
                    myGroup.enter()
                    
                    let data = document.data()
                    let cardInfo = GlobalCards(cardIDString: data["global_card_id"] as? String, cardNameString: data["card_name"] as? String, iconString: data["icon"] as? String, cardCategoryString: data["card_category"] as? String, cardDescriptionString: data["card_description"] as? String, orderNum: data["order_number"] as? NSNumber, createdInLatNum: data["created_in_lat"] as? NSNumber, createdInLonNum: data["created_in_lon"] as? NSNumber, createdInLocationString: data["created_in_location"] as? String, tagsArray: data["tags"] as? [String], usesCurrentLocationBool: data["uses_current_location"] as? Bool, usesSpotifyBool: data["uses_spotify"] as? Bool, mapDataBool: data["map_data"] as? Bool, accordionDataBool: data["accordion_data"] as? Bool, tableDataBool: data["table_data"] as? Bool, refreshRadiusNum: data["refresh_radius"] as? NSNumber, refreshTimeNum: data["refresh_time"] as? NSNumber, versionInt: data["version"] as? Int, settingsGroupIDsArray: data["settings_group_ids"] as? [String])
                    
                    cardInformation.append(cardInfo)
                    myGroup.leave()
                }
            }
        }
        
        myGroup.notify(queue: .main) {
            response(cardInformation)
        }
    }

    
    
}


