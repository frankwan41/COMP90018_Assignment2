//
//  LocationManager.swift
//  COMP90018_APP
//
//  Created by Junran Lin on 14/9/2023.
//

import Foundation
import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate{
    var manager = CLLocationManager()
    
    @Published var location: CLLocationCoordinate2D?
    @Published var isLoading = false
    
    override init() {
        super.init()
        manager.delegate = self
        
    }
    
    
    func requestLocation() {
        isLoading = true
        manager.requestLocation()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        location = locations.first?.coordinate
        isLoading = false
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error){
        print("Encountered error while getting location, \(error)")
        isLoading = false
    }
}
