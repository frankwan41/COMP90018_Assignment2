//
//  TabView.swift
//  COMP90018_APP
//
//  Created by frank w on 14/9/2023.
//

import SwiftUI

struct TabMainView: View {
    
    @State var shakeResult: String = ""
    @State var searchCategory: String = ""
    
    @State private var isActive: Bool = false
    @State private var selectedTab: Int = 0
    
    @StateObject var userViewModel = UserViewModel()
    @StateObject var postsViewModel = PostsViewModel()
    
    @State private var showLoginAlert = false
    
    var body: some View {
        NavigationStack {
            TabView {
                PostsView(
                    searchCategory: $searchCategory,
                    userViewModel: userViewModel,
                    postsViewModel: postsViewModel
                )
                    .navigationBarBackButtonHidden(true)
                    .tabItem {
                        Image(systemName: "fork.knife")
                        Text("Posts")
                    }
                    
                ProfileView(userViewModel: userViewModel)
                    .navigationBarBackButtonHidden(true)
                    .tabItem {
                        Image(systemName: "person")
                        Text("Profile")
                    }
            }
            .onAppear {
                let tabBarAppearance = UITabBarAppearance()
                tabBarAppearance.configureWithDefaultBackground()
                UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
            }
            .withFooter()

            .tint(.black)
            // Customize an add button to tab items to start a post
            .overlay(
                Button(action: {
                    if(userViewModel.isLoggedIn){
                        isActive = true
                    }
                    else{
                        showLoginAlert = true
                    }
                    
                }) {
                    Image(systemName: "plus.app.fill")
                        .resizable()
                        .frame(width: 45, height: 40)
                        .foregroundColor(.orange)
                        .background(.white)
                        .cornerRadius(10)
                }
                    .alert(isPresented: $showLoginAlert) {
                        Alert(
                            title: Text("Login Required"),
                            message: Text("You need to log in to create post."),
                            dismissButton: .default(Text("OK"))
                            
                        )
                    }
                    .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height - UIScreen.main.bounds.height * 0.138)
                    .fullScreenCover(isPresented: $isActive, content: {
                        // Your destination view goes here
                        AddPostView()
                            .onDisappear{
                                // Refresh code
                                if searchCategory != "" {
                                    postsViewModel.fetchPosts(tag: searchCategory)
                                } else {
                                    postsViewModel.fetchPosts()
                                }
                            }
                    })
            )
        }
        
    }
}

struct PhotoView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            Text("This is the take phot page")
            Button("Dismiss") {
                presentationMode.wrappedValue.dismiss()
            }
            .padding()
        }
    }
}
