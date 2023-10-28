import SwiftUI
import Kingfisher


enum TabSelection: Int, CaseIterable {
    case posts = 0
    case liked = 1
}

struct ProfileView: View {

    @ObservedObject var userViewModel: UserViewModel
    @StateObject var profileViewModel = ProfileViewModel()
    @StateObject var postsViewModel = PostsViewModel()
    @State private var showLoginAlert = false
    @State private var wantsLogin = false
    
    @State private var likeStates: [Bool] = Array(repeating: false, count: 20)
    @State private var heartScale: CGFloat = 1.0
    @State private var numLikeStates: [Int] = Array(repeating: 32, count: 20)
    @State private var showLoginSheet = false
    
    @State private var selectedTab: TabSelection = .posts
    
//    let gradientStart = Color.orange.opacity(0.5)
//    let gradientEnd = Color.orange
    
    // Before Modification
//    let gradientBackground = LinearGradient(gradient: Gradient(colors: [Color.orange.opacity(0.5), Color.orange]), startPoint: .top, endPoint: .bottom)
    
    let gradientBackground = LinearGradient(gradient: Gradient(colors: [Color.orange, Color.white]), startPoint: .top, endPoint: .bottom)
    
    let postGradientBackground = LinearGradient(gradient: Gradient(colors: [Color.orange.opacity(0.01), Color.orange.opacity(0.01)]), startPoint: .top, endPoint: .bottom)

    var body: some View {

        NavigationView {
            ZStack {
                gradientBackground.edgesIgnoringSafeArea(.all)

                VStack(spacing: 20) {
                    if !userViewModel.isLoggedIn {
                        guestView
                    } else {
                        loggedInView
                            .refreshable {
                                profileViewModel.getUserInformation()
                                profileViewModel.getUserPosts()
                            }
                            
                    }
                }
                .padding(.horizontal)
                .navigationBarItems(trailing: userViewModel.isLoggedIn ? logoutButton : nil)
                
            }
            .onAppear {
                if !userViewModel.isLoggedIn {
                    showLoginAlert = true
                }
                profileViewModel.getUserInformation()
                profileViewModel.getUserPosts()
            }
            .onChange(of: userViewModel.isLoggedIn, perform: { newValue in
                if newValue {
                    wantsLogin = false
                    profileViewModel.getUserInformation()
                    profileViewModel.getUserPosts()
                }
            })
            .sheet(isPresented: $wantsLogin) {
                SignView(userViewModel: userViewModel)
                    .onDisappear {
                        if !userViewModel.isLoggedIn {
                            showLoginAlert = true
                        }
                        wantsLogin = false
                    }
            }
        }
    }

    
}


// MARK: COMPONENTS

extension ProfileView {
    
    private var guestView: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.gray)

            Text("Welcome Guest!")
                .font(.largeTitle)
                .bold()

            Text("Log in or sign up to access your profile.")
                .font(.headline)
                .multilineTextAlignment(.center)

            Button(action: { wantsLogin = true }) {
                Text("Log In or Sign Up")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.orange)
                    .cornerRadius(10)
            }
        }
    }

    private var loggedInView: some View {
        VStack(spacing: 15) {
            HStack(alignment: .top,spacing: 10){
                if let url = URL(string: profileViewModel.user.profileImageURL) {
                    KFImage(url)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                        .shadow(radius: 10)
                } else {
                    Image(systemName: "person.circle")
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                        .shadow(radius: 10)
                }
                VStack{
                    Text(profileViewModel.user.userName)
                        .font(.largeTitle)
                        .bold()
                    
                    NavigationLink(destination: ProfileSetttingView(profileSettingViewModel: ProfileSettingViewModel(), profileViewModel: profileViewModel)) {
                        Text("Modify Profile Details")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.orange)
                            .cornerRadius(20)
                    }
                    
                }
            }
            Divider()
            
            Picker("", selection: $selectedTab) {
                            ForEach(TabSelection.allCases, id: \.self) { tab in
                                Text(tab == .posts ? "Posts" : "Liked").tag(tab)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding()
            
            
            if selectedTab == .posts {
                
                if profileViewModel.posts.isEmpty{
                    Text("💔Sorry, you don't have any posts yet.")
                        .frame(alignment: .center)
                        .bold()
                        .font(.headline)
                        .opacity(0.8)
                        .padding(.vertical, 5)
                    
//                    ProgressView()
//                        .padding(.top, 2)
//                        .padding(.bottom, 2)
                }
                List{
                    AllPostsView(
                        isLoggedIn: $userViewModel.isLoggedIn,
                        posts: $profileViewModel.posts,
                        postsViewModel: postsViewModel,
                        gradientBackground: postGradientBackground
                    )
                }.listStyle(.plain)
            } else if selectedTab == .liked {
                // Replace with your LikedPostsView or a modified AllPostsView
                // that displays liked posts.
                
                if profileViewModel.likedPosts.isEmpty{
                    
                    Text("💔Sorry, You don't have liked posts yet.")
                        .frame(alignment: .center)
                        .bold()
                        .font(.headline)
                        .opacity(0.8)
                        .padding(.vertical, 5)
                    
                    
//                    ProgressView()
//                        .padding(.top, 2)
//                        .padding(.bottom, 2)
                }
                
                
                List{
                    AllPostsView(
                        isLoggedIn: $userViewModel.isLoggedIn,
                        posts: $profileViewModel.likedPosts,
                        gradientBackground: postGradientBackground
                    )
                }.listStyle(.plain)
            }
            

        }
        .onChange(of: selectedTab, perform: { value in
            profileViewModel.getUserInformation()
            profileViewModel.getUserPosts()
        })
    }

    private var logoutButton: some View {
        Button(action: {
            userViewModel.signOutUser()
        }) {
            Text("Sign Out")
                .foregroundColor(.white)
            
                .bold()
        }
    }
}

//struct ProfileView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProfileView()
//    }
//}
