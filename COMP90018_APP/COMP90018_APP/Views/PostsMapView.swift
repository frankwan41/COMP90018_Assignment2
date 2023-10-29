//
//  PostsMapView.swift
//  COMP90018_APP
//
//  Created by frank w on 29/10/2023.
//

import SwiftUI
import CoreLocation
import MapKit
import Kingfisher

// Distinguish post location and user current location
enum MapAnnotationItem: Identifiable {
    case post(Post)
    case currentLocation(CLLocationCoordinate2D)

    var id: String {
        switch self {
        case .post(let post):
            return post.id
        case .currentLocation:
            return UUID().uuidString
        }
    }
}

struct CustomMapAnnotationView: View {
    var item: MapAnnotationItem
    let type: MapAnnotationItem
    
    var body: some View {
        switch type {
        case .post(let post):
            // Custom view for a post
            if post.latitude != 0 && post.longitude != 0 {
                HStack(spacing: 1) {
                    if let urlString = post.imageURLs.first {
                        if urlString.isEmpty{
                            ProgressView("Loading...")
                                .controlSize(.large)
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 30, height: 20, alignment: .center)
                                .tint(.orange)
                        }else{
                            let url = URL(string: urlString)
                            KFImage(url)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .font(.largeTitle)
                                .frame(maxWidth: 30, maxHeight: 20)
                        }
                    }
                    VStack{
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                        Text("\(post.likes)")
                            .fixedSize()
                        
                    }
                }.padding(10)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 25.0, style: .continuous))
                    .overlay(
                        Image(systemName: "arrowtriangle.left.fill")
                            .rotationEffect(Angle(degrees: 270))
                            .foregroundColor(.white)
                            .offset(y: 10)
                        
                        , alignment: .bottom)
            }
        case .currentLocation:
            // Custom view for the current location
            VStack {
                Image("locationIcon")
                    .resizable()
                    .frame(width: 18, height: 20)
                Text("Me")
                    .fixedSize()
            }.padding(10)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 25.0, style: .continuous))
                .overlay(
                    Image(systemName: "arrowtriangle.left.fill")
                        .rotationEffect(Angle(degrees: 270))
                        .foregroundColor(.white)
                        .offset(y: 10)
                    
                    , alignment: .bottom)
            
            
        }
    }
}


struct PostsMapView: View {
    @ObservedObject var locationManager: LocationManager
    @Binding var posts: [Post]
    var mapRange: CLLocationDistance = 1000 // meters
    
    var currentLocationMapImage = ["https://images.unsplash.com/photo-1619468129361-605ebea04b44?auto=format&fit=crop&q=60&w=900&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Nnx8cGlufGVufDB8fDB8fHww"]

    @State private var region: MKCoordinateRegion

    init(locationManager: LocationManager, posts: Binding<[Post]>) {
        self._locationManager = ObservedObject(wrappedValue: locationManager)
        self._posts = posts
        let initialCoordinate = locationManager.location ??
            CLLocationCoordinate2D(latitude: -37.79927042919155, longitude: 144.96286139745774) // Default location
        self._region = State(initialValue: MKCoordinateRegion(center: initialCoordinate, latitudinalMeters: 1000, longitudinalMeters: 1000))
    }

    var body: some View {
        VStack{
            
            Map(coordinateRegion: $region, annotationItems: allAnnotations) { item in
                
                switch item {
                case .post(let post):
                    MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: post.latitude, longitude: post.longitude)) {
                        CustomMapAnnotationView(item: item, type: item)
                    }
                case .currentLocation(let location):
                    MapAnnotation(coordinate: location) {
                        CustomMapAnnotationView(item: item, type: item)
                    }
                }
            }

        }
        .onAppear{
            if let currentLocation = locationManager.location {
                region = MKCoordinateRegion(center: currentLocation, latitudinalMeters: mapRange, longitudinalMeters: mapRange)
            }
        }
    }
    
    var allAnnotations: [MapAnnotationItem] {
        var annotations = posts.map { MapAnnotationItem.post($0) }
        if let currentLocationCoordinate = locationManager.location {
            annotations.append(.currentLocation(currentLocationCoordinate))
        }
        return annotations
    }
}
