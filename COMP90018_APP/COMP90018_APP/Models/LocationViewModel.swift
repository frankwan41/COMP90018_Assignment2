//
//  LocationViewModel.swift
//  COMP90018_APP
//
//  Created by frank w on 25/10/2023.
//

import Foundation
import MapKit

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
