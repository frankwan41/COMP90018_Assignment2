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


struct PostsMapView: View {
    
    @State var user: User? = nil

    @ObservedObject var locationManager: LocationManager
    @ObservedObject var userViewModel: UserViewModel
    @ObservedObject var postsViewModel: PostsViewModel
        
    @State private var filteredPosts: [Post] = []
    @State private var selectedIndex: Int = 0
    @Binding var posts: [Post]
    
    @State private var selectedLocation: String = ""
    
    var mapRange: CLLocationDistance = 1000 // meters

    @State private var region: MKCoordinateRegion

    init(locationManager: LocationManager,userViewModel: UserViewModel,postsViewModel:PostsViewModel, posts: Binding<[Post]>) {
        self._locationManager = ObservedObject(wrappedValue: locationManager)
        self._userViewModel = ObservedObject(wrappedValue: userViewModel)
        self._postsViewModel = ObservedObject(wrappedValue: postsViewModel)
        self._posts = posts
        let initialCoordinate = locationManager.location ??
            CLLocationCoordinate2D(latitude: -37.79927042919155, longitude: 144.96286139745774) // Default location
        self._region = State(initialValue: MKCoordinateRegion(center: initialCoordinate, latitudinalMeters: 1000, longitudinalMeters: 1000))
        
        // Perform the filtering of posts here
        let filtered = posts.wrappedValue.filter { $0.latitude != 0 && $0.longitude != 0 }
        self._filteredPosts = State(initialValue: filtered)
        
        // Set the selectedLocation
        if let firstFilteredPost = filtered.first {
            self._selectedLocation = State(initialValue: firstFilteredPost.location)
        }
        
        if let currentLocation = locationManager.location {
            self._region = State(initialValue: locationManager.region)
        }
    }

    var body: some View {
        
            ZStack(alignment: .bottom) {
                
                Map(coordinateRegion: $region, annotationItems: allAnnotations) { item in
                    
                    switch item {
                    case .post(let post):
                        MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: post.latitude, longitude: post.longitude)) {
                            CustomMapAnnotationView(item: item, type: item, selectedLocation: $selectedLocation)
                                
                        }
                    case .currentLocation(let location):
                        MapAnnotation(coordinate: location) {
                            CustomMapAnnotationView(item: item, type: item, selectedLocation: $selectedLocation)

                        }
                    }
                }
                
                
                ForEach(filteredPosts) {post in
                    if post.location == selectedLocation {
                        SinglePostPreview(post: post, isLoggedIn: $userViewModel.isLoggedIn, postsViewModel: postsViewModel)
                            .frame(height: 200)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 25))
                            .overlay{
                                
                                Button {
                                    prevPost()
                                } label: {
                                    VStack(spacing: 10){
                                        Image(systemName: "arrowshape.turn.up.left.fill")
                                        Text("Prev")
                                    }
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                                }
                                .offset(x: -150, y: -35)
                                
                                NavigationLink {
                                    SinglePostView(post: post).navigationBarBackButtonHidden(true)
                                } label: {
                                    VStack(spacing: 1){
                                        Image(systemName: "info.circle.fill")
                                            .fontWeight(.bold)
                                            .foregroundStyle(.black)
                                        Text("Read")
                                            .font(.caption)
                                            .foregroundStyle(.black)
                                    }
                                    
                                }
                                .offset(y: 35)

                                
                                Button {
                                    nextPost()
                                } label: {
                                    VStack(spacing: 10){
                                        Image(systemName: "arrowshape.turn.up.right.fill")
                                        Text("Next")
                                    }
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                                }
                                .offset(x: 150, y: -35)
                                
                            }
                        
                    }
                }
                
            }
        .onAppear{
            
            userViewModel.getCurrentUser { user in
                self.user = user
            }
            
            
        }
    }
    
    func prevPost(){
        if filteredPosts.count > 0{
            let prevIndex = selectedIndex - 1
            guard filteredPosts.indices.contains(prevIndex) else {
                selectedIndex = filteredPosts.count - 1
                selectedLocation = filteredPosts[selectedIndex].location
                updateRegion(latitude: filteredPosts[selectedIndex].latitude, longitude: filteredPosts[selectedIndex].longitude)
                return
            }
            selectedIndex = prevIndex
            selectedLocation = filteredPosts[selectedIndex].location
            
            updateRegion(latitude: filteredPosts[selectedIndex].latitude, longitude: filteredPosts[selectedIndex].longitude)
            print(selectedIndex)
            print(selectedLocation)
        }
    }
    
    func nextPost(){
        if filteredPosts.count > 0{
            let nextIndex = selectedIndex + 1
            guard filteredPosts.indices.contains(nextIndex) else {
                selectedIndex = 0
                selectedLocation = filteredPosts[selectedIndex].location
                updateRegion(latitude: filteredPosts[selectedIndex].latitude, longitude: filteredPosts[selectedIndex].longitude)
                return
            }
            selectedIndex = nextIndex
            selectedLocation = filteredPosts[selectedIndex].location
            
            updateRegion(latitude: filteredPosts[selectedIndex].latitude, longitude: filteredPosts[selectedIndex].longitude)
            
            print(selectedIndex)
            print(selectedLocation)
        }
    }
    
    func updateRegion(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let postCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        region = MKCoordinateRegion(center: postCoordinate, latitudinalMeters: mapRange, longitudinalMeters: mapRange)
    }
    
    var allAnnotations: [MapAnnotationItem] {
        var annotations = filteredPosts.map { MapAnnotationItem.post($0) }
        if let currentLocationCoordinate = locationManager.location {
            annotations.append(.currentLocation(currentLocationCoordinate))
        }
        return annotations
    }
}

// MARK: COMPONENTS

struct CustomMapAnnotationView: View {
    var item: MapAnnotationItem
    let type: MapAnnotationItem
    
    @Binding var selectedLocation: String
    
    var body: some View {
        switch type {
        case .post(let post):
            // Custom view for a post
                HStack {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                        Text("\(post.likes)")
                            .fixedSize()
                        
                }.padding(5)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 25.0, style: .continuous))
                .scaleEffect(post.location == selectedLocation ? 1.3 : 0.7)
                    .overlay(
                        Image(systemName: "arrowtriangle.left.fill")
                            .rotationEffect(Angle(degrees: 270))
                            .foregroundColor(.white)
                            .scaleEffect(post.location == selectedLocation ? 1.5 : 0.7)
                            .offset(y: 10)
                        
                        , alignment: .bottom)
                    .onTapGesture {
                        print(selectedLocation)
                        print(post.location)
                        selectedLocation = post.location
                    }
        case .currentLocation:
            // Custom view for the current location
            VStack {
                Image("locationIcon")
                    .resizable()
                    .frame(width: 15, height: 17)
            }.padding(5)
                .background(Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: 25.0, style: .continuous))
                .overlay(
                    Image(systemName: "arrowtriangle.left.fill")
                        .rotationEffect(Angle(degrees: 270))
                        .foregroundColor(.blue)
                        .offset(y: 10)
                    
                    , alignment: .bottom)
            
            
        }
    }
}
