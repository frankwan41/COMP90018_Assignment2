//
//  PostsView.swift
//  COMP90018_APP
//
//  Created by frank w on 14/9/2023.
//

import SwiftUI
import Kingfisher

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
                List {
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
                    AllPostsView(
                        heartScale: $heartScale,
                        isLoggedIn: $userViewModel.isLoggedIn,
                        showLoginSheet: $showLoginSheet,
                        posts: $postViewModel.posts
                    )
                }
                .listStyle(.plain)
                .toolbar {
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

    @Binding var heartScale: CGFloat
    @Binding var isLoggedIn: Bool
    @Binding var showLoginSheet: Bool
    @State private var showLoginAlert = false
    
    @Binding var post: Post
    @State var user: User? = nil
    
    @State var isLiked: Bool = false
    
    @StateObject var userViewModel = UserViewModel()
    
    var body: some View {
        Button {
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
            Image(systemName: isLiked ? "heart.fill" : "heart")
                .scaleEffect(heartScale)
                .foregroundColor(isLiked ? .red : .gray)
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
        .onAppear {
            getCurrentUser { user in
                if let user = user {
                    self.user = user
                    isLiked = user.likedPostsIDs.contains(post.id)
                }
            }
        }
        // TODO: detect login information with .onChange()
        .onChange(of: userViewModel.isLoggedIn, perform: { newValue in
            if !newValue {
                isLiked = false
            }
        })
    }
    
    // Toggle number of likes, +1 / -1
    func toggleLikes() {
        if var currentUser = user {
            isLiked.toggle()
            if isLiked {
                currentUser.likedPostsIDs.append(post.id)
                post.likes += 1
            } else {
                currentUser.likedPostsIDs.removeAll { $0 == post.id }
                post.likes -= 1
            }
            updateUserInformation(newLikedPostsIDs: currentUser.likedPostsIDs)
            updatePostInformation(postID: post.id, newLikes: post.likes)
            user = currentUser
        }
    }
}

struct SinglePostPreview: View {
    @State var post: Post
    @Binding var heartScale: CGFloat
    @Binding var isLoggedIn: Bool
    @Binding var showLoginSheet: Bool
    
    @State var user: User? = nil
    @State var profileImageURL: String? = nil
    
    var body: some View {
        ZStack {
            VStack(alignment:.leading, spacing: 10){
                if let urlString = post.imageURLs.first {
                    let url = URL(string: urlString)
                    KFImage(url)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .font(.largeTitle)
                        .frame(maxWidth: 600, maxHeight: 400)
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .font(.largeTitle)
                        .frame(maxWidth: 600, maxHeight: 400)
                }
                Text(post.postTitle).font(.headline)
                HStack(spacing: 4){
                    if let urlString = profileImageURL {
                        let url = URL(string: urlString)
                        KFImage(url)
                            .resizable()
                            .frame(maxWidth: 30, maxHeight: 30)
                            .clipped()
                            .cornerRadius(50)
                            .overlay(RoundedRectangle(cornerRadius: 44).stroke(Color(.label), lineWidth: 1))
                    } else {
                        Image(systemName: "person.circle")
                            .resizable()
                            .frame(maxWidth: 30, maxHeight: 30)
                            .clipped()
                            .cornerRadius(50)
                            .overlay(RoundedRectangle(cornerRadius: 44).stroke(Color(.label), lineWidth: 1))
                    }
                    Text(post.userName).font(.subheadline)
                    Spacer()
                    LikeButton(
                        heartScale: $heartScale,
                        isLoggedIn: $isLoggedIn,
                        showLoginSheet: $showLoginSheet,
                        post: $post
                    )
                    Text(String(post.likes)).font(.subheadline)
                }
            }
            .padding()
            NavigationLink(destination: SinglePostView().navigationBarBackButtonHidden(true)) {
                EmptyView()
            }
            .opacity(0)  // Making the NavigationLink invisible
            .allowsHitTesting(false)
        }
        .onAppear {
            getUser(userUID: post.userUID) { user in
                if let user = user {
                    self.user = user
                    profileImageURL = user.profileImageURL
                } else {
                    profileImageURL = nil
                }
            }
        }
    }
    
}

struct AllPostsView: View {
    @Binding var heartScale: CGFloat
    @Binding var isLoggedIn: Bool
    @Binding var showLoginSheet: Bool
    @Binding var posts: [Post]
    
    var body: some View {
        ForEach(Array(posts.enumerated()), id: \.element.id) { (index, post) in
            SinglePostPreview(
                post: post,
                heartScale: $heartScale,
                isLoggedIn: $isLoggedIn,
                showLoginSheet: $showLoginSheet
            )
        }
    }
}

// MARK: Functions
private func getUser(userUID: String, completion: @escaping (User?) -> Void) {
    FirebaseManager.shared.firestore
        .collection("users")
        .document(userUID)
        .getDocument { documentSnapshot, error in
            if let error = error {
                print("Unable to fetch the details of the user \(userUID), \(error.localizedDescription)")
                completion(nil)
            } else if let documentSnapshot = documentSnapshot, let data = documentSnapshot.data() {
                let user = User(data: data)
                print("Successfully fetched the user \(userUID)")
                completion(user)
            } else {
                completion(nil)
            }
    }
}

private func getCurrentUser(completion: @escaping (User?) -> Void) {
    guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
        completion(nil)
        return
    }
    
    getUser(userUID: uid) { user in
        completion(user)
    }
}

private func updateUserInformation(newLikedPostsIDs: [String]){
    
    // Cherck whether the user has logined
    // uid = Auth.auth().currentUser?.uid
    guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
        print("Unable to get the uid of the user, check the login state.")
        return
    }
    
    let updatedData = [
        "likedpostsids": newLikedPostsIDs
    ] as [String: Any]
    
    FirebaseManager.shared.firestore
        .collection("users")
        .document(uid)
        .updateData(updatedData)
    
    print("Successfully updated the details of user \(uid).")
    
}

private func updatePostInformation(postID: String, newLikes: Int) {
    let updatedData = [
        "likes": newLikes
    ] as [String: Any]
    
    FirebaseManager.shared.firestore
        .collection("posts")
        .document(postID)
        .updateData(updatedData)
    
    print("Successfully updated the details of post \(postID).")
}


struct PostsView_Previews: PreviewProvider {
    static var previews: some View {
        PostsView()
    }
}
