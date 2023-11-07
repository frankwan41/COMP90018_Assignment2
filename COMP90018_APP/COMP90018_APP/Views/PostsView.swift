//
//  PostsView.swift
//  COMP90018_APP
//
//  Created by frank w on 14/9/2023.
//

import SwiftUI
import Kingfisher

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
    
    @EnvironmentObject var speechRecognizer: SpeechRecognizerViewModel
    var shakeCommand = "shake"
    
    var body: some View {
       
        NavigationView {
            ZStack {
                backgroundColor.edgesIgnoringSafeArea(.all)
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
            
            // Filter posts to only keep those with tags that fuzzily match the search term
            postsViewModel.fetchPostsBySearch(searchCategory: searchCategory)
            
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
                TextField(
                    "Search tag...",
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
            
            if !shakeResult.isEmpty {
                if postsViewModel.posts.isEmpty {
                    Text("💔Sorry, No Post About \(shakeResult)")
                        .frame(alignment: .center)
                        .bold()
                        .font(.headline)
                        .opacity(0.8)
                        .padding(.vertical, 5)
                } else {
                    Text("💝Posts For \(shakeResult)")
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
