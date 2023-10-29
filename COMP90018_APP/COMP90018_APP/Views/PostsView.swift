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
                    
                    if showPostsMapView{
                        PostsMapView(locationManager: locationManager,userViewModel: userViewModel, postsViewModel: postsViewModel, posts: $postsViewModel.posts)
                    }else{
                        
                        Group{
                            if postsViewModel.posts.isEmpty{
                                if searchCategory.isEmpty{
                                    ProgressView()
                                        .padding(.bottom, 2)
                                }
                                
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
                            .listRowBackground(postGradientBackground)
                            
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
                                    postCollectionModel: postsViewModel,
                                    gradientBackground: postGradientBackground
                                )
                            }
                            .listStyle(.plain)
                        }
                        .padding(.horizontal, 5)
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
        .task {
            searchCategory = shakeResult
            processUserInput()
        }
    }
    
    // when user press return, search the tag
    func processUserInput() {
        // Now you can use userInput to perform any operations you need
        if searchCategory != "" {
            postsViewModel.fetchPosts(tag: searchCategory)
        } else {
            postsViewModel.fetchPosts()
        }
    }
}
