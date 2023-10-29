//
//  LocationViewModel.swift
//  COMP90018_APP
//
//  Created by frank w on 25/10/2023.
//

import Foundation
import MapKit

struct Place: Identifiable{
    let id = UUID().uuidString
    private var mapItem: MKMapItem
    
    init(mapItem: MKMapItem) {
        self.mapItem = mapItem
    }
    
    var name: String {
        self.mapItem.name ?? ""
    }
    
    var address: String {
        let placemark = self.mapItem.placemark
        var cityAndState = ""
        var address = ""
        
        cityAndState = placemark.locality ?? "" // city
        if let state = placemark.administrativeArea {
            // Show either state or city, state
            cityAndState = cityAndState.isEmpty ? state : "\(cityAndState), \(state)"
        }
        
        address = placemark.subThoroughfare ?? "" // address number
        if let street = placemark.thoroughfare {
            // Show the street unless there is a street number, then add street
            address = address.isEmpty ? street : "\(address) \(street)"
        }
        
        if address.trimmingCharacters(in: .whitespaces).isEmpty && !cityAndState.isEmpty {
            // No address
            address = cityAndState
        } else {
            // No city and state
            address = cityAndState.isEmpty ? address : "\(address), \(cityAndState)"
        }
        
        return address
    }
    
    var latitude: CLLocationDegrees {
        self.mapItem.placemark.coordinate.latitude
    }
    
    var longitude: CLLocationDegrees {
        self.mapItem.placemark.coordinate.longitude
    }
    
}

class LocationViewModel: ObservableObject {
    @Published var places: [Place] = []

    func search(text: String = "", region: MKCoordinateRegion) {
            let searchRequest = MKLocalSearch.Request()
            if text.isEmpty {
                // If the text is empty, search for generic categories.
                searchRequest.naturalLanguageQuery = "place"
            } else {
                searchRequest.naturalLanguageQuery = text
            }
            searchRequest.region = region
            let search = MKLocalSearch(request: searchRequest)
            
            search.start { response, error in
                guard let response = response else {
                    print("Error: \(error?.localizedDescription ?? "Unknown Error")")
                    return
                }
                
                self.places = response.mapItems.map(Place.init)
            }
        }
}
