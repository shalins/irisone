//
//  AppDelegate.swift
//  Iris
//
//  Created by Shalin Shah on 1/4/20.
//  Copyright © 2020 Shalin Shah. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import SpotifyLogin
import Mixpanel

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var locationManager: CLLocationManager!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.configureAPIs()
        self.authorizationLogic()
        self.configureUserLocation()
        
        Mixpanel.mainInstance().track(event: "App Opened")
        
        return true
    }
    
    func configureAPIs() {
        NetworkSession.shared.initSessionManager()
        FirebaseApp.configure()
        SpotifyLogin.shared.configure(clientID: "57b313adf5b14eaa8ccdefc5f82c7971", clientSecret: "571ddaa7a5c44c858a3b565004bb0fb4", redirectURL: URL(string: "iris://spotify-login-callback")!)
        Mixpanel.initialize(token: "47c544ae1153521b92fe62ee78f4be33")
    }
    
    func grabStoryboard() -> UIStoryboard {
        // determine screen size
        let screenHeight = UIScreen.main.bounds.size.height
        let screenWidht = UIScreen.main.bounds.size.width
        var storyboard: UIStoryboard! = nil
        
        if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone) {
            if ( screenHeight == 812 && screenWidht == 375) {
                // iphone xs
                storyboard = UIStoryboard.init(name: "MainXS", bundle: nil)
            } else if (screenHeight == 896 && screenWidht == 414) {
                // iphone x max
                storyboard = UIStoryboard.init(name: "Main", bundle: nil)
            } else if (screenHeight == 736 && screenWidht == 414) {
                // iphone 7+ and 8+
                storyboard = UIStoryboard.init(name: "MainPlus", bundle: nil)
            } else {
                // iphone 7 and 8
                storyboard = UIStoryboard.init(name: "Main8", bundle: nil)
            }
        }
        return storyboard
    }
    
    func startWithSignUp() {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let storyboard = self.grabStoryboard()
        let start: FirstScreenViewController? = storyboard.instantiateViewController()
        self.window?.rootViewController = start
        self.window?.makeKeyAndVisible()
    }
        
    func startWithCardList() {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let storyboard = self.grabStoryboard()
        let start: InstallCardsViewController? = storyboard.instantiateViewController()
//        let start: EnterYearViewController? = storyboard.instantiateViewController()
        self.window?.rootViewController = start
        self.window?.makeKeyAndVisible()
    }
    
    func startWithHome() {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let storyboard = self.grabStoryboard()
        let start: HomeViewController? = storyboard.instantiateViewController()
        self.window?.rootViewController = start
        self.window?.makeKeyAndVisible()
    }
    
    func startWithLocation() {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let storyboard = self.grabStoryboard()
        let start: LocationPermissionViewController? = storyboard.instantiateViewController()
        self.window?.rootViewController = start
        self.window?.makeKeyAndVisible()
    }

    
    func authorizationLogic() {
//        try? Auth.auth().signOut()
        if let _ = Auth.auth().currentUser {
            Mixpanel.mainInstance().identify(distinctId: Mixpanel.mainInstance().distinctId)
            do {
                let users = try DataController.shared.context.fetch(User.fetchRequest() as NSFetchRequest<User>)
                if (users.count > 0) {
                    // check if cards count is > 1 or not
                    let cards = try DataController.shared.getCards(fromUser: users.last)
                    if (cards?.count ?? 0 > 0) {
                        let status = CLLocationManager.authorizationStatus()
                        if (status == .notDetermined) {
                            self.startWithLocation()
                        } else {
                            self.startWithHome()
                        }
                    } else {
                        self.startWithCardList()
                    }
                } else {
                    self.startWithSignUp()
                }
            } catch {
                self.startWithSignUp()
            }
        } else {
            self.startWithSignUp()
        }
    }
}


import MapKit
import CoreLocation

struct UserLocation {
    static var userlocation : CLLocation! = CLLocation(latitude: 37.870456, longitude: -122.2540443)
    static var latitude: Double! = 37.870456
    static var longitude: Double! = -122.2540443
}

extension AppDelegate: CLLocationManagerDelegate, MKMapViewDelegate {
    func configureUserLocation() {

        locationManager = CLLocationManager()
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation

        locationManager.delegate = self
        
        let status = CLLocationManager.authorizationStatus()
        if (status != .notDetermined) {
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard locations.last != nil else {
            return
        }
        UserLocation.userlocation = CLLocation(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        UserLocation.latitude = locations[0].coordinate.latitude
        UserLocation.longitude = locations[0].coordinate.longitude
        if let _ = Auth.auth().currentUser {
            do {
                let users = try DataController.shared.context.fetch(User.fetchRequest() as NSFetchRequest<User>)
                if (users.count > 0) {
                    guard let user = try? DataController.shared.getUser(fromID: Auth.auth().currentUser?.uid ?? "") else { return }
                    try? DataController.shared.updateUserLocation(user: user, lat: UserLocation.latitude, lon: UserLocation.longitude)
                }
            } catch {
                return
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        locationManager.stopUpdatingLocation()
    }
}

extension AppDelegate {
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let handled = SpotifyLogin.shared.applicationOpenURL(url) { (error) in }
        return handled
    }
}
