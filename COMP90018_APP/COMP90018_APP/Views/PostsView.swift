//
//  PostsView.swift
//  COMP90018_APP
//
//  Created by frank w on 14/9/2023.
//

import SwiftUI
import Kingfisher

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
    
    @EnvironmentObject var speechRecognizer: SpeechRecognizerViewModel
    var shakeCommand = "shake"
    
    let gradientBackground = LinearGradient(
        gradient: Gradient(colors: [Color.orange, Color.white]),
        startPoint: .top,
        endPoint: .bottom
    )
    
    let postGradientBackground = LinearGradient(
        gradient: Gradient(colors: [Color.orange.opacity(0.1), Color.orange.opacity(0.1)]),
        startPoint: .top,
        endPoint: .bottom
    )
    
    var body: some View {
       
        NavigationView {
            ZStack {
                gradientBackground.edgesIgnoringSafeArea(.all)
                VStack {
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
                            .frame(width: 20, height: 20)
                            .foregroundStyle(.black)
                    }.padding()
                    
                    // MUST HAVE THIS IF !!!!!!! NO IDEA WHY !!!!!!!!
                    if showPostsMapView{
                        PostsMapView(locationManager: locationManager,userViewModel: userViewModel, postsViewModel: postsViewModel, posts: $postsViewModel.posts)
                            .opacity(showPostsMapView ? 1 : 0)
                            .frame(maxHeight: showPostsMapView ? .infinity : 0)
                    }
                    PostsListView
                        .opacity(showPostsMapView ? 0 : 1)
                        .frame(maxHeight: showPostsMapView ? 0 : .infinity)
                    HStack {
                                            Spacer()
                                        }
                }
                .toolbar {
                    
                    if userViewModel.isLoggedIn{
                        ToolbarItem(placement: .topBarLeading) {
                            HStack{
                                Button {
                                    viewSwitcher = viewPage.chat
                                } label: {
                                    Image(systemName: "message.circle.fill")
                                }
                                
                                Text("Chat")
                                    .font(.headline)
                                    .italic()
                                    .bold()
                                    .background(Color.orange.opacity(0.5))
                                    .padding(.horizontal, 1)
                            }
                        }
                    }
                    
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            viewSwitcher = viewPage.shake
                        } label: {
                            Image(systemName: "dice")
                        }
                        
                    }
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
        .refreshable {
            // Refresh code
            processUserInput()
        }
        .onAppear {
            searchCategory = shakeResult
            processUserInput()
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
    }

}



extension PostsView {
    private var PostsListView: some View {
        VStack{
            if postsViewModel.posts.isEmpty && searchCategory.isEmpty {
                ProgressView().padding(.bottom, 2)
            }
            HStack {
                Picker("", selection: $searchType) {
                    ForEach(SearchTypes.allCases) { type in
                        Text(type.rawValue.capitalized).tag(type)
                            
                    }
                }
                .padding(.trailing, -10)
                .pickerStyle(.menu)
                
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
                    Button("Cancel") {
                        searchCategory = ""
                        shakeResult = ""
                        isSearchFocused = false
                        processUserInput()
                    }
                    .padding(.trailing)
                }
            }
            .listRowBackground(postGradientBackground)
            
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
                        Text("Searching category: \(searchType.rawValue)")
                        Text("💝Posts For \(shakeResult)")
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
                    postCollectionModel: postsViewModel,
                    gradientBackground: postGradientBackground
                )
            }
            .listStyle(.plain)
        }
        .padding(.horizontal, 5)
    }
}
