import Foundation
import CoreLocation
import MapKit

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    var manager = CLLocationManager()
        
        @Published var location: CLLocationCoordinate2D?
    @Published var region = MKCoordinateRegion()
    @Published var locationString: String = ""
        
        override init() {
            super.init()
            manager.desiredAccuracy = kCLLocationAccuracyBest
            manager.distanceFilter = kCLDistanceFilterNone
            manager.startUpdatingLocation()
            manager.delegate = self

        }
    
    func requestPermission(completion: @escaping (Bool) -> Void) {
            let status = manager.authorizationStatus
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                // Permissions have already been granted
                completion(true)
            case .notDetermined:
                // Request permissions
                manager.requestWhenInUseAuthorization()
                self.completionHandler = completion
            default:
                // Permissions have been denied or restricted
                completion(false)
            }
        }
    
        private var completionHandler: ((Bool) -> Void)?
    
        
        func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
            switch manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                completionHandler?(true)
            case .denied, .restricted:
                completionHandler?(false)
                print("Location authorization is \(manager.authorizationStatus.rawValue)")
            case .notDetermined:
                print("Location authorization waiting...")
            @unknown default:
                completionHandler?(false)
                print("Unknown authorization status: \(manager.authorizationStatus.rawValue)")
            }
            completionHandler = nil
        }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Locations: \(locations)")
        self.location = locations.first?.coordinate
        guard let loc = locations.last else {return}
        self.region = MKCoordinateRegion(center: loc.coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
        
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: location!.latitude, longitude: location!.longitude)
        
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            guard let placemark = placemarks?.first, error == nil else {
                print("No placemarks found or an error occurred: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            let addressString = "\(placemark.locality ?? ""), \(placemark.administrativeArea ?? ""), \(placemark.country ?? "")"
            print(addressString)
            self.locationString = addressString
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Encountered error while getting location, \(error)")
    }

}
