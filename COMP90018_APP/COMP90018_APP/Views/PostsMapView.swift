//
//  PostsMapView.swift
//  COMP90018_APP
//
//  Created by frank w on 29/10/2023.
//

import SwiftUI
import MapKit

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
    @State private var selectedIndex: Int
    @Binding var posts: [Post]
        
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
        
        // Perform the filtering of posts to discard posts without location
        let filtered = posts.wrappedValue.filter { $0.latitude != 0 && $0.longitude != 0 }
        self._filteredPosts = State(initialValue: filtered)
        
        // Set the selectedIndex
        self._selectedIndex = State(initialValue: filtered.first != nil ? 0 : -1)
        
    }

    var body: some View {
        
            VStack {
                
                // Create map annotation for all posts with valid latitude and lontitude, as well as indicate user current position
                Map(coordinateRegion: $region, annotationItems: allAnnotations) { item in
                    
                    switch item {
                    case .post(let post):
                        MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: post.latitude, longitude: post.longitude)) {
                            CustomMapAnnotationView(item: item, type: item, filteredPosts: $filteredPosts, selectedIndex: $selectedIndex)
                                
                        }
                    case .currentLocation(let location):
                        MapAnnotation(coordinate: location) {
                            CustomMapAnnotationView(item: item, type: item,filteredPosts: $filteredPosts, selectedIndex: $selectedIndex)

                        }
                    }
                }
                .padding(.bottom, -20)
                
                
                ForEach(filteredPosts.indices, id: \.self) {index in
                    let bindingPost = $filteredPosts[index]
                    if index == selectedIndex {
                        PostCard(
                            post: bindingPost,
                            userViewModel: userViewModel,
                            postCollectionModel: postsViewModel
                        )
                            .frame(height: 200)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 25))
                            .overlay{
                                
                                // Button to last post
                                Button {
                                    prevPost()
                                } label: {
                                    VStack(spacing: 10){
                                        Image(systemName: "arrowshape.turn.up.left.fill")
                                        Text("Prev")
                                    }
                                    .fontWeight(.bold)
                                    .foregroundStyle(.black)
                                }
                                .offset(x: -170, y: -70)
                                
                                
                                // Navigation link to the single post
                                NavigationLink {
                                    SinglePostView(post: bindingPost).navigationBarBackButtonHidden(true)
                                } label: {
                                    VStack(spacing: 1){
                                        Image(systemName: "info.circle.fill")
                                            .font(.system(size: 12))
                                            .foregroundStyle(.black)
                                        
                                        // Create an transparent section for navigation
                                        Rectangle()
                                            .fill(Color.clear)
                                            .frame(width: 100, height: 70)
                                    }
                                }
                                .offset(y: -56)

                                // Button to next post
                                Button {
                                    nextPost()
                                } label: {
                                    VStack(spacing: 10){
                                        Image(systemName: "arrowshape.turn.up.right.fill")
                                        Text("Next")
                                    }
                                    .fontWeight(.bold)
                                    .foregroundStyle(.black)
                                }
                                .offset(x: 170, y: -70)
                                
                            }
                        
                    }
                }
                
            }
        .onAppear{
            
            userViewModel.getCurrentUser { user in
                self.user = user
            }
            
            // Set the selectedIndex to the closest post
            if let userLocation = locationManager.location, let closestIndex = indexOfNearestPost(to: userLocation) {
                selectedIndex = closestIndex
                // Set the region to include both locations
                let postLocation = CLLocationCoordinate2D(latitude: filteredPosts[closestIndex].latitude, longitude: filteredPosts[closestIndex].longitude)
                region = regionIncludingLocations(userLocation, postLocation)
            }
            
        }
    }
    
    // Decrease the selected index to navigate to previous post, if reaches 0 index, then set the index to the end
    func prevPost(){
        if filteredPosts.count > 0{
            let prevIndex = selectedIndex - 1
            guard filteredPosts.indices.contains(prevIndex) else {
                selectedIndex = filteredPosts.count - 1
                updateRegion(latitude: filteredPosts[selectedIndex].latitude, longitude: filteredPosts[selectedIndex].longitude)
                return
            }
            selectedIndex = prevIndex
            
            updateRegion(latitude: filteredPosts[selectedIndex].latitude, longitude: filteredPosts[selectedIndex].longitude)

        }
    }
    
    // Increase the selected index to navigate to next post, if reaches maximum index, then set the index to the begining
    func nextPost(){
        if filteredPosts.count > 0{
            let nextIndex = selectedIndex + 1
            guard filteredPosts.indices.contains(nextIndex) else {
                selectedIndex = 0
                updateRegion(latitude: filteredPosts[selectedIndex].latitude, longitude: filteredPosts[selectedIndex].longitude)
                return
            }
            selectedIndex = nextIndex
            
            updateRegion(latitude: filteredPosts[selectedIndex].latitude, longitude: filteredPosts[selectedIndex].longitude)

        }
    }
    
    // Update map region to show to user
    func updateRegion(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let postCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        region = MKCoordinateRegion(center: postCoordinate, latitudinalMeters: mapRange, longitudinalMeters: mapRange)
    }
    
    // Initialize region with cloest post and the current location
    func regionIncludingLocations(_ location1: CLLocationCoordinate2D, _ location2: CLLocationCoordinate2D) -> MKCoordinateRegion {
        let middlePoint = CLLocationCoordinate2D(
            latitude: (location1.latitude + location2.latitude) / 2,
            longitude: (location1.longitude + location2.longitude) / 2
        )
        
        let latDelta = abs(location1.latitude - location2.latitude) * 2.0
        let lonDelta = abs(location1.longitude - location2.longitude) * 2.0
        
        // Make sure the deltas are not too small to avoid an extremely zoomed in view
        let span = MKCoordinateSpan(
            latitudeDelta: max(latDelta, 0.01),
            longitudeDelta: max(lonDelta, 0.01)
        )
        
        return MKCoordinateRegion(center: middlePoint, span: span)
    }




    
    // Calculate the post with the cloest distance to the current locaiton
    func indexOfNearestPost(to location: CLLocationCoordinate2D) -> Int? {
        guard !filteredPosts.isEmpty else { return nil }
        
        let distances = filteredPosts.map { post in
            CLLocation(latitude: post.latitude, longitude: post.longitude).distance(from: CLLocation(latitude: location.latitude, longitude: location.longitude))
        }
        
        if let closestIndex = distances.enumerated().min(by: { $0.element < $1.element })?.offset {
            return closestIndex
        }
        
        return nil
    }

    
    // Generate map items including posts and current device location
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
    
    @Binding var filteredPosts: [Post]
    @Binding var selectedIndex: Int
    
    var body: some View {
        switch type {
        case .post(let post):
                // Display number of likes of the post, apply scale effect if the post is selected
                HStack {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                        Text("\(post.likes)")
                            .fixedSize()
                        
                }.padding(5)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 25.0, style: .continuous))
                .scaleEffect(filteredPosts.firstIndex(where: {$0.id == post.id}) == selectedIndex ? 1.3 : 0.7)
                    .overlay(
                        Image(systemName: "arrowtriangle.left.fill")
                            .rotationEffect(Angle(degrees: 270))
                            .foregroundColor(.white)
                            .scaleEffect(filteredPosts.firstIndex(where: {$0.id == post.id}) == selectedIndex ? 1.5 : 0.7)
                            .offset(y: 10)
                        
                        , alignment: .bottom)
                    .onTapGesture {
                        print(post)
                        if let index = filteredPosts.firstIndex(where: { $0.id == post.id}){
                            print(index)
                            selectedIndex = index
                        }
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
