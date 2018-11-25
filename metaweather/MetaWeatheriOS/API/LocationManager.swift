//
//  LocationManager.swift
//  iXNYCodeChallenge
//
//  Created by Marcos Rodriguez on 8/4/18.
//  Copyright © 2018 Marcos Rodríguez Vélez. All rights reserved.
//

import UIKit
import CoreLocation

protocol LocationManagerDelegate: class {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
}

class LocationManager: NSObject {
    
    static let shared: LocationManager = LocationManager()
    private let locationManager: CLLocationManager = CLLocationManager()
    var delegate: LocationManagerDelegate?
    var location: CLLocation?
    
    typealias completionHandler = () -> ()
    private var managerCompletionHander: completionHandler?
    
    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocationAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func requestLocation(completionHandler: @escaping () -> ()) {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestLocation()
            self.managerCompletionHander = completionHandler
        }
    }
    
}

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        delegate?.locationManager(locationManager, didChangeAuthorization: status)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first
        managerCompletionHander?()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        delegate?.locationManager(locationManager, didFailWithError: error)
        managerCompletionHander?()
    }
}
