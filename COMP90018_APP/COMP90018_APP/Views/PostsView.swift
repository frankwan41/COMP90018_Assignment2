//
//  PostsView.swift
//  COMP90018_APP
//
//  Created by frank w on 14/9/2023.
//

import SwiftUI
import Kingfisher
import CoreLocation

enum SearchTypes: String,CaseIterable,Identifiable {
    case tag = "tag"
    case user = "user"
    case post = "post"
    
    var id: Self { self }
}

struct PostsView: View {

    @Binding var searchCategory: String
    @FocusState private var isSearchFocused: Bool
    
    @AppStorage("viewDisplay") var viewSwitcher = viewPage.welcome
    @AppStorage("shakeResult") var shakeResult = ""
    
    @ObservedObject var userViewModel: UserViewModel
    @ObservedObject var postsViewModel: PostsViewModel
    
    @StateObject var locationManager = LocationManager()
  
    @State private var shouldShowProfile = false
    @State private var showPostsMapView = false
    @State private var searchType: SearchTypes = .tag
    @State private var pickerIsActive = false
    @State private var showDropDown = false
    
    @State var sortOrder = "Most Recent"
    let orders = ["Most Recent", "Most Popular", "Nearest"]
    
    @State var userLocationActive = false
    @State var showActivateConfirmation = false
    
    @EnvironmentObject var speechRecognizer: SpeechRecognizerViewModel
    var shakeCommand = "shake"
    
    var body: some View {
       
        NavigationView {
            ZStack {
                backgroundColor.edgesIgnoringSafeArea(.all)
                VStack {
                    
                    Spacer().frame(height: 10)
                    HStack {
                        
                        Spacer().frame(width: 25)
                        
                        if userViewModel.isLoggedIn {
                            Button {
                                viewSwitcher = viewPage.chat
                            } label: {
                                Image(systemName: "message.circle.fill")
                                    .resizable().scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .foregroundStyle(.black)
                            }
                        }

                        Spacer()

                        Button {
                            locationManager.requestPermission { authorized in
                                if authorized {
                                    showPostsMapView.toggle()
                                } else {
                                    return
                                }
                            }
                        } label: {
                            Image(systemName: "map.fill")
                                .resizable().scaledToFit()
                                .frame(width: 30, height: 30)
                                .foregroundStyle(.black)
                        }

                        Spacer()

                        Button {
                            viewSwitcher = viewPage.shake
                        } label: {
                            Image(systemName: "dice")
                                .resizable().scaledToFit()
                                .frame(width: 30, height: 30)
                                .foregroundStyle(.black)
                        }
                        Spacer().frame(width: 20)
                    }
                    Spacer().frame(height: 10)
                    
                    // MUST HAVE THIS IF !!!!!!! NO IDEA WHY !!!!!!!!
                    if showPostsMapView{
                        PostsMapView(locationManager: locationManager,userViewModel: userViewModel, postsViewModel: postsViewModel, posts: $postsViewModel.posts)
                            .opacity(showPostsMapView ? 1 : 0)
                            .frame(maxHeight: showPostsMapView ? .infinity : 0)
                    }
                    PostsListView
                        .opacity(showPostsMapView ? 0 : 1)
                        .frame(maxHeight: showPostsMapView ? 0 : .infinity)
                }
            }
            NavigationLink(
                destination: ProfileView(userViewModel: userViewModel),
                isActive: $shouldShowProfile
            ) { EmptyView() }
        }
        .onChange(of: speechRecognizer.commandText, perform: { value in
            print(value)
            if speechRecognizer.commandText.lowercased().contains(shakeCommand) {
                DispatchQueue.main.async {
                    viewSwitcher = .shake
                }
            }
        })
        .onChange(of: searchType, perform: { newValue in
            processUserInput()
        })
        .onChange(of: sortOrder, perform: { newValue in
            sortPosts()
        })
        .refreshable {
            // Refresh code
            processUserInput()
        }
        .onAppear {
            searchCategory = shakeResult
            processUserInput()
        }
    }
    
    func sortPosts() {
        if (sortOrder == "Most Recent") {
            postsViewModel.posts.sort { $0.timestamp > $1.timestamp }
        } else if (sortOrder == "Most Popular") {
            postsViewModel.posts.sort { $0.likes > $1.likes }
        } else if (sortOrder == "Nearest") {
            locationManager.requestPermission { authorized in
                if authorized {
                    requestAndUpdateLocationForBeingActive()
                    postsViewModel.posts.sort { calculateDistance(post: $0) > calculateDistance(post: $1) }
                } else {
                    sortOrder = "Most Recent"
                }
            }
        }
    }
    
    func calculateDistance(post: Post) -> CLLocationDistance{
        let currentUserCoordinate = CLLocation(latitude: userViewModel.currentUser?.currentLatitude ?? 0, longitude: userViewModel.currentUser?.currentLongitude ?? 0)
        let selectedUserCoordinate = CLLocation(latitude: post.latitude, longitude: post.longitude)
        return currentUserCoordinate.distance(from: selectedUserCoordinate).rounded()
    }
    
    private func requestAndUpdateLocationForBeingActive(){
        // Request location
        locationManager.requestPermission { authorized in
            if authorized{
                // Update the current location of the user
                if let location = locationManager.location{

                    self.userViewModel.updateUserCurrentLocation(latitude: location.latitude, longitude: location.longitude) { result in
                        if result == nil{
                            userLocationActive = false
                        } else {
                            
                            // Update the active state of the user
                            self.userViewModel.setUserActiveState(state: true) { info in
                            if info != nil{
                                userLocationActive = true
                            }else{
                                userLocationActive = false
                            }
                        }
                            
                        }
                    }
                    
                }else{
                    // Unable to update the location of the user
                    userLocationActive = false
                }
            }else{
                // Unable to update the location of the user
                showActivateConfirmation = true
                userLocationActive = false
                
            }
        }
    }
    
    // when user press return, search the tag
    func processUserInput() {
        if !searchCategory.isEmpty {
            
            switch searchType {
            case .tag:
                // Filter posts to only keep those with tags that fuzzily match the search term
                postsViewModel.fetchPostsBySearch(searchCategory: searchCategory)
            case .user:
                postsViewModel.fetchPostsByUsername(searchUsername: searchCategory)
            case .post:
                postsViewModel.fetchPostsByTitleOrContent(searchText: searchCategory)
            }
            
            
        } else {
            
            // If there is no search term, display all posts
            // This may require calling another method to re-fetch all posts
            postsViewModel.fetchPosts()
            
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
            sortPosts()
        })
    }

}

extension PostsView {
    private var PostsListView: some View {
        VStack{
            if postsViewModel.posts.isEmpty && searchCategory.isEmpty {
                ProgressView().padding(.bottom, 2)
            }
            HStack {
                Spacer().frame(width: 10)
                HStack{
                    Picker("Tag", selection: $searchType) {
                        ForEach(SearchTypes.allCases) { type in
                            Text(type.rawValue.capitalized).tag(type)
                            
                        }
                    }
                    //.padding(.leading, -10)
                    //.padding(.trailing, -10)
                    .pickerStyle(.menu)
                    .bold()
                    .padding(.vertical, 4)
                }
                .background(.white.opacity(0.5))
                
                .cornerRadius(20)
                
                TextField(
                    "Search \(searchType.rawValue)...",
                    text: $searchCategory,
                    onEditingChanged: { isEditing in
                        isSearchFocused = isEditing
                        if (isSearchFocused) {
                            searchCategory = searchCategory
                                .trimmingCharacters(in: .whitespacesAndNewlines)
                                .lowercased()
                            shakeResult = searchCategory
                            processUserInput()
                        }
                    }
                )
                .focused($isSearchFocused)
                .padding(10)
                .background(Color.white.opacity(0.5))
                .cornerRadius(20)
                
                if isSearchFocused || !searchCategory.isEmpty {
                    Spacer().frame(width: 20)
                    Button("Cancel") {
                        searchCategory = ""
                        shakeResult = ""
                        isSearchFocused = false
                        processUserInput()
                    }
                }
                Spacer().frame(width: 20)
            }
            
            Picker("Sort By", selection: $sortOrder) {
                ForEach(orders, id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 20)
            
            if !shakeResult.isEmpty {
                if postsViewModel.posts.isEmpty {
                    Text("💔Sorry, No \(searchType.rawValue) About \(shakeResult)")
                        .frame(alignment: .center)
                        .bold()
                        .font(.headline)
                        .opacity(0.8)
                        .padding(.vertical, 5)
                } else {
                    VStack{
                        Text("Searching 💝Posts For ")
                        Text("\(shakeResult) in \(searchType.rawValue)")
                    }
                        .frame(alignment: .center)
                        .bold()
                        .font(.headline)
                        .opacity(0.8)
                        .padding(.vertical, 5)
                }
            }
            
            List {
                PostCollection(
                    userViewModel: userViewModel,
                    postCollectionModel: postsViewModel
                )
            }
            .listStyle(.plain)
        }
    }
}
