import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    var manager = CLLocationManager()
        
        @Published var location: CLLocationCoordinate2D?
        @Published var isLoading = false
        
        override init() {
            super.init()
            manager.delegate = self
            manager.desiredAccuracy = kCLLocationAccuracyBest
            manager.distanceFilter = kCLDistanceFilterNone

        }
        
        func requestLocation() {
            switch manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                isLoading = true
                manager.requestLocation()
            case .notDetermined:
                manager.requestWhenInUseAuthorization()  // Request permission
            case .denied, .restricted:
                print("Location authorization is \(manager.authorizationStatus.rawValue)")
            @unknown default:
                print("Unknown authorization status: \(manager.authorizationStatus.rawValue)")
            }
        }
        
        func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
            switch manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                requestLocation()
            case .denied, .restricted, .notDetermined:
                print("Location authorization is \(manager.authorizationStatus.rawValue)")
                isLoading = false
            @unknown default:
                print("Unknown authorization status: \(manager.authorizationStatus.rawValue)")
                isLoading = false
            }
        }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Locations: \(locations)")
        location = locations.first?.coordinate
        print("Locations: \(self.location)")
        isLoading = false
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Encountered error while getting location, \(error)")
        isLoading = false
    }

}
