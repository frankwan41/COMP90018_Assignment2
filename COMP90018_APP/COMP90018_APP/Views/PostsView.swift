//
//  PostsView.swift
//  COMP90018_APP
//
//  Created by frank w on 14/9/2023.
//

import SwiftUI

struct PostsView: View {
//    @State var shakeResult: String  = ""
    @State private var searchCategory: String = ""
    @FocusState private var isSearchFocused: Bool
    
    
    @State private var likeStates: [Bool] = Array(repeating: false, count: 20)
    @State private var heartScale: CGFloat = 1.0
    @State private var numLikeStates: [Int] = Array(repeating: 32, count: 20)
    
    @AppStorage("viewDisplay") var viewSwitcher = viewPage.welcome
    @AppStorage("shakeResult") var shakeResult = ""
    
    @StateObject var userViewModel = UserViewModel() // <-- Add this line
    @State private var showLoginSheet = false       // <-- Add this line
    @State private var shouldShowProfile = false
    @StateObject var postViewModel = PostsViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                List{
                    HStack {
                        TextField("Search tag...", text: $searchCategory, onEditingChanged: { isEditing in
                            isSearchFocused = isEditing
                        })
                            .focused($isSearchFocused)
                            .padding(10)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                        
                        if isSearchFocused || !searchCategory.isEmpty{
                            Button("Cancel") {
                                searchCategory = ""
                                isSearchFocused = false
                            }
                            .padding(.trailing)
                        }
                    }
                    Text("Here is your shake result: \(shakeResult)")
                    AllPostsView(likeStates: $likeStates, heartScale: $heartScale, numLikeStates: $numLikeStates, isLoggedIn: $userViewModel.isLoggedIn, showLoginSheet: $showLoginSheet, posts: $postViewModel.posts)
                }
                .listStyle(.plain)
                .toolbar{
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            viewSwitcher = viewPage.shake
                        } label: {
                            Image(systemName: "dice")
                        }
                        
                        
                    }
            }
            }
            NavigationLink(destination: ProfileView(), isActive: $shouldShowProfile) {
                            EmptyView()
                        }
        }
    }
}

// MARK: COMPONENTS

struct LikeButton: View {
    let index: Int
    
    @Binding var likeStates: [Bool]
    @Binding var heartScale: CGFloat
    @Binding var numLikeStates: [Int]
    @Binding var isLoggedIn: Bool
    @Binding var showLoginSheet: Bool
    @State private var showLoginAlert = false
    
    
    var body: some View{
        Button {
            print(isLoggedIn)
            if isLoggedIn {
                withAnimation {
                    // Slightly increase the size for a moment
                    heartScale = 1.5
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    withAnimation {
                        heartScale = 1.0 // Return to normal size
                    }
                }
                toggleLikes()
            } else {
                showLoginAlert = true
            }
        } label: {
            Image(systemName: likeStates[index] ? "heart.fill" : "heart")
                .scaleEffect(heartScale)
                .foregroundColor(likeStates[index] ? .red : .gray)
            
        }
        .alert(isPresented: $showLoginAlert) {
            Alert(
                title: Text("Login Required"),
                message: Text("You need to be logged in to like posts."),
                dismissButton: .default(Text("OK"), action: {
                    showLoginSheet = true
                })
                
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // Toggle number of likes, +1 / -1
    func toggleLikes(){
        likeStates[index].toggle()
        if likeStates[index] {
            numLikeStates[index] += 1
        }else{
            numLikeStates[index] -= 1
        }
    }
}

struct AllPostsView: View {
    @Binding var likeStates: [Bool]
    @Binding var heartScale: CGFloat
    @Binding var numLikeStates: [Int]
    @Binding var isLoggedIn: Bool
    @Binding var showLoginSheet: Bool
    @Binding var posts: [Post]
    
    var body: some View {
        ForEach(Array(posts.enumerated()), id: \.element.id) { (index, post) in
            ZStack {
                VStack(alignment:.leading, spacing: 10){
                    //TODO: Fetch Image
                    Image(systemName: "photo")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .font(.largeTitle)
                    Text(post.postTitle).font(.headline)
                    HStack(spacing: 4){
                        Image(systemName: "person.circle")
                        Text(post.userName).font(.subheadline)
                        Spacer()
                        LikeButton(index: index,
                                   likeStates: $likeStates,
                                   heartScale: $heartScale,
                                   numLikeStates: $numLikeStates,
                                   isLoggedIn: $isLoggedIn,
                                   showLoginSheet: $showLoginSheet)
                        Text("\(numLikeStates[index])").font(.subheadline)
                    }
                }
                .padding()
                NavigationLink(destination: SinglePostView().navigationBarBackButtonHidden(true)) {
                    EmptyView()
                }
                .opacity(0)  // Making the NavigationLink invisible
                .allowsHitTesting(false)
            }
        }
    }
}


struct PostsView_Previews: PreviewProvider {
    static var previews: some View {
        PostsView()
    }
}
