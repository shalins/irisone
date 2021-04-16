//
//  LocationPermissionViewController.swift
//  Iris
//
//  Created by Shalin Shah on 1/30/20.
//  Copyright © 2020 Shalin Shah. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import FirebaseAuth
import CoreData
import Mixpanel

class LocationPermissionViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    var locationManager: CLLocationManager!

    @IBOutlet weak var enableLocation: UIButton! {
        didSet {
            self.enableLocation.roundCorners([.allCorners], radius: 5.0)
            self.enableLocation.backgroundColor = UIColor.ColorTheme.Blue.Electric
            self.enableLocation.titleLabel?.font = UIFont(name: "NunitoSans-Bold", size: 16)
            self.enableLocation.layer.shouldRasterize = true
            self.enableLocation.layer.rasterizationScale = UIScreen.main.scale
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    @IBAction func enableLocationPushed(_ sender: Any) {
        self.configureUserLocation()
    }
    
    func configureUserLocation() {

        locationManager = CLLocationManager()
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation

        locationManager.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard locations.last != nil else {
            return
        }
        print("updating from location vc")
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
    
    func goHome() {
        DispatchQueue.main.async {
            Mixpanel.mainInstance().track(event: "Completed Onboarding")
            let next: HomeViewController? = self.storyboard?.instantiateViewController()
            self.show(next!, sender: self)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            Mixpanel.mainInstance().people.set(properties: ["Location Allowed": true])
            self.goHome()
        } else if status == .denied {
            Mixpanel.mainInstance().people.set(properties: ["Location Allowed": false])
            self.goHome()
        } else if status == .notDetermined {
            Mixpanel.mainInstance().people.set(properties: ["Location Allowed": false])
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        locationManager.stopUpdatingLocation()
    }

}
