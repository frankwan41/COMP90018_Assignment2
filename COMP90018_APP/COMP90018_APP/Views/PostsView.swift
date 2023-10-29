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
    
//    let gradientStart = Color.orange.opacity(0.5)
//    let gradientEnd = Color.orange
    
    // Before Modification
//    let gradientBackground = LinearGradient(gradient: Gradient(colors: [Color.orange.opacity(0.5), Color.orange]), startPoint: .top, endPoint: .bottom)
    
    let gradientBackground = LinearGradient(gradient: Gradient(colors: [Color.orange, Color.white]), startPoint: .top, endPoint: .bottom)
    
    let postGradientBackground = LinearGradient(gradient: Gradient(colors: [Color.orange.opacity(0.1), Color.orange.opacity(0.1)]), startPoint: .top, endPoint: .bottom)
    
    
    
    var body: some View {
       
        
        NavigationView {
            ZStack{
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
                        PostsMapView(locationManager: locationManager, posts: $postsViewModel.posts)
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
                                        // when user press return will call this function
                                        if (isSearchFocused == true){
                                            searchCategory = searchCategory.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                                            shakeResult = searchCategory
                                            processUserInput()
                                        }
                                    }
                                )
                                .focused($isSearchFocused)
                                
                                .padding(10)
                                .background(Color.white.opacity(0.5))
                                .cornerRadius(20)
                                
                                if isSearchFocused || !searchCategory.isEmpty{
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
                            
                            
                            if !shakeResult.isEmpty{
                                if postsViewModel.posts.isEmpty{
                                    Text("💔Sorry, No Post About \(shakeResult)")
                                        .frame(alignment: .center)
                                        .bold()
                                        .font(.headline)
                                        .opacity(0.8)
                                        .padding(.vertical, 5)
                                }else{
                                    Text("💝Posts For \(shakeResult)")
                                        .frame(alignment: .center)
                                        .bold()
                                        .font(.headline)
                                        .opacity(0.8)
                                        .padding(.vertical, 5)
                                    
                                }
                            }
                            
                            if !isSearchFocused{
                                
                            }
                            
                            List {
                                
                                
                                
                                AllPostsView(
                                    isLoggedIn: $userViewModel.isLoggedIn,
                                    posts: $postsViewModel.posts,
                                    postsViewModel: postsViewModel,
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
            
            NavigationLink(destination: ProfileView(userViewModel: userViewModel), isActive: $shouldShowProfile) {
                EmptyView()
            }
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
        .task{
            
            searchCategory = shakeResult
            processUserInput()
            
        }
    }
    
    // when user press return, search the tag
    func processUserInput() {
        // Now you can use userInput to perform any operations you need
        if searchCategory != "" {
            postsViewModel.fetchPostsByTag(tag: searchCategory.trimmingCharacters(in: .whitespacesAndNewlines).lowercased())
        }else{
            postsViewModel.fetchAllPosts()
        }
    }
}

// MARK: COMPONENTS

struct LikeButton: View {
    
    let isSinglePostView: Bool
    
    @Binding var isLoggedIn: Bool
    @Binding var post: Post
    @State var user: User? = nil
    

    @State var heartScale: CGFloat = 1.0
    @State var showLoginSheet: Bool = false
    @State private var showLoginAlert = false
    
    @State var isLiked: Bool = false
    
    
    @StateObject var userViewModel = UserViewModel()
    @StateObject var singlePostViewModel = SinglePostViewModel()
    @StateObject var likeButtonCompoModel = SinglePostPreviewCompoModel()
    
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
            if isSinglePostView {
                Image(systemName: isLiked ? "heart.fill" : "heart")
                    .resizable()
                    .frame(width: 30, height: 25)
                    .scaleEffect(heartScale)
                    .foregroundColor(isLiked ? .red : .black)
                    .padding(.vertical)
            } else {
                Image(systemName: isLiked ? "heart.fill" : "heart")
                    .scaleEffect(heartScale)
                    .foregroundColor(isLiked ? .red : .gray)
            }
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
            userViewModel.getCurrentUser { user in
                if let user = user {
                    self.user = user
                    isLiked = user.likedPostsIDs.contains(post.id)
                }
            }
            
            likeButtonCompoModel.getPost(postID: post.id) { postNew in
                post.likes = postNew?.likes ?? post.likes
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
            userViewModel.clickPostLikeButton(postID: post.id)
            singlePostViewModel.updatePostLikes(postID: post.id, newLikes: post.likes)
        }
    }
}

struct SinglePostPreview: View {
    
    @State var post: Post

    @Binding var isLoggedIn: Bool
    
    @State var user: User? = nil
    @State var profileImageURL: String? = nil
    
    @StateObject var userViewModel = UserViewModel()
    @ObservedObject var postsViewModel: PostsViewModel
    @StateObject var singlePostPreviewModel = SinglePostPreviewCompoModel()
    
    let postGradientBackground = LinearGradient(gradient: Gradient(colors: [Color.orange.opacity(0.85), Color.white.opacity(0.1)]), startPoint: .top, endPoint: .bottom)
    
    var body: some View {
        ZStack {
            postGradientBackground.edgesIgnoringSafeArea(.all)
            VStack(spacing: 10){
                if let urlString = post.imageURLs.first {
                    if urlString.isEmpty{
                        //Image(systemName: "photo.stack")
                        //.resizable()
                        ProgressView("Loading...")
                            .controlSize(.large)
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 300, height: 200, alignment: .center)
                            .tint(.orange)
                    }else{
                        let url = URL(string: urlString)
                        KFImage(url)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .font(.largeTitle)
                            .frame(maxWidth: 600, maxHeight: 400)
                    }
                } else {
//                    Image(systemName: "photo.stack")
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .font(.largeTitle)
//                        .frame(maxWidth: 600, maxHeight: 400)
                }
                
                VStack(alignment: .leading){
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
                        if post.userUID == userViewModel.getUserUID() {
                            DeleteButton(post: $post, postsViewModel: postsViewModel)
                        }
                        LikeButton(
                            isSinglePostView: false,
                            isLoggedIn: $isLoggedIn,
                            post: $post
                        )
                        Text(String(post.likes)).font(.subheadline)
                    }
                    
                }
                
                
            }
            .padding()
            NavigationLink(destination: SinglePostView(post: post).navigationBarBackButtonHidden(true)) {
                EmptyView()
            }
            .opacity(0)  // Making the NavigationLink invisible
            .allowsHitTesting(false)
        }
        .onAppear {
            userViewModel.getUser(userUID: post.userUID) { user in
                if let user = user {
                    self.user = user
                    profileImageURL = user.profileImageURL
                } else {
                    profileImageURL = nil
                }
            }
            
            singlePostPreviewModel.getPost(postID: post.id) { newPost in
                post.imageURLs = newPost?.imageURLs ?? post.imageURLs
            }
        }
    }
    
}

struct AllPostsView: View {

    @Binding var isLoggedIn: Bool
    @Binding var posts: [Post]
    @StateObject var postsViewModel = PostsViewModel()
    
    var gradientBackground: LinearGradient
    
    var body: some View {
        ForEach(Array(posts.enumerated()), id: \.element.id) { (index, post) in
            SinglePostPreview(post: post, isLoggedIn: $isLoggedIn, postsViewModel: postsViewModel)
                .listRowBackground(gradientBackground)
        }
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 25))
    }
}

struct DeleteButton: View {
    
    @Binding var post: Post
    @ObservedObject var postsViewModel: PostsViewModel

    @State var deleteScale: CGFloat = 1.0
    @State private var showAlert: Bool = false
    
    var body: some View {
        Button {
            withAnimation {
                // Slightly increase the size for a moment
                deleteScale = 1.5
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                withAnimation {
                    deleteScale = 1.0 // Return to normal size
                }
            }
            showAlert = true
        } label: {
            Image(systemName: "trash")
                .scaleEffect(deleteScale)
                .foregroundColor(.gray)
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Delete Confirmation"),
                message: Text("Are you sure you want to delete this post?"),
                primaryButton: .destructive(Text("Delete"), action: {
                    postsViewModel.removePost(postID: post.id)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        postsViewModel.fetchAllPosts()
                    }
                }),
                secondaryButton: .cancel()
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
}

//struct PostsView_Previews: PreviewProvider {
//    static var previews: some View {
//        PostsView()
//    }
//}
