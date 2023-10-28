import SwiftUI
import Kingfisher


enum TabSelection: Int, CaseIterable {
    case posts = 0
    case liked = 1
}

struct ProfileView: View {

    @ObservedObject var userViewModel: UserViewModel
    @StateObject var profileViewModel = ProfileViewModel()

    @State private var showLoginAlert = false
    @State private var wantsLogin = false
    
    @State private var selectedTab: TabSelection = .posts
    
    let gradientBackground = LinearGradient(
        gradient: Gradient(colors: [Color.orange, Color.white]),
        startPoint: .top,
        endPoint: .bottom
    )
    
    let postGradientBackground = LinearGradient(
        gradient: Gradient(colors: [Color.orange.opacity(0.01), Color.orange.opacity(0.01)]),
        startPoint: .top,
        endPoint: .bottom
    )

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
                                profileViewModel.fetchPosts()
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
                profileViewModel.fetchPosts()
            }
            .onChange(of: userViewModel.isLoggedIn, perform: { newValue in
                if newValue {
                    wantsLogin = false
                    profileViewModel.getUserInformation()
                    profileViewModel.fetchPosts()
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
                    ProgressView()
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
                    ProgressView()
                        .padding(.top, 2)
                        .padding(.bottom, 2)
                }
                List{
                    PostCollection(
                        userViewModel: userViewModel,
                        postCollectionModel: profileViewModel,
                        gradientBackground: gradientBackground
                    )
                }.listStyle(.plain)
            } else if selectedTab == .liked {
                // Replace with your LikedPostsView or a modified AllPostsView
                // that displays liked posts.
                
                if profileViewModel.likedPosts.isEmpty{
                    ProgressView()
                        .padding(.top, 2)
                        .padding(.bottom, 2)
                }
                
                
                List {
                    PostCollection(
                        userViewModel: userViewModel,
                        postCollectionModel: profileViewModel,
                        gradientBackground: gradientBackground
                    )
                }.listStyle(.plain)
            }
            

        }
        .onChange(of: selectedTab, perform: { value in
            profileViewModel.getUserInformation()
            profileViewModel.fetchPosts()
        })
    }

    private var logoutButton: some View {
        Button(action: {
            userViewModel.signOutUser()
        }) {
            Text("Sign Out")
                .foregroundColor(.orange)
                .bold()
        }
    }
}
