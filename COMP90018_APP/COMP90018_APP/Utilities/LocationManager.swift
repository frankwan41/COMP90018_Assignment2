import Foundation
import CoreLocation

enum LoadingStatus {
    case loading
    case success
    case failed
    case denied
    case defaults
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    var manager = CLLocationManager()
        
        @Published var location: CLLocationCoordinate2D?
    @Published var isLoading: LoadingStatus = .defaults
    @Published var locationString: String = ""
        
        override init() {
            super.init()
            manager.delegate = self

        }
        
        func requestLocation() {
            switch manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                isLoading = .loading
                manager.requestLocation()
            case .notDetermined:
                isLoading = .loading
                manager.requestWhenInUseAuthorization()  // Request permission
            case .denied, .restricted:
                isLoading = .denied
                print("Location authorization is \(manager.authorizationStatus.rawValue)")
            @unknown default:
                print("Unknown authorization status: \(manager.authorizationStatus.rawValue)")
            }
        }
        
        func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
            switch manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                requestLocation()
            case .denied, .restricted:
                print("Location authorization is \(manager.authorizationStatus.rawValue)")
                isLoading = .denied
            case .notDetermined:
                isLoading = .defaults
                print("Location authorization waiting...")
            @unknown default:
                print("Unknown authorization status: \(manager.authorizationStatus.rawValue)")
                isLoading = .failed
            }
        }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Locations: \(locations)")
        location = locations.first?.coordinate
        isLoading = .success
        
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
        isLoading = .failed
    }

}
