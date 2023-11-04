import SwiftUI
import Kingfisher


enum TabSelection: Int, CaseIterable {
    case posts = 0
    case liked = 1
}

struct ProfileView: View {

    @ObservedObject var userViewModel: UserViewModel
    @StateObject var profileViewPostsModel = ProfileViewPostsModel()
    @StateObject var profileViewLikedModel = ProfileViewLikedModel()
    @EnvironmentObject var speechRecognizer: SpeechRecognizerViewModel

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
                                refresh()
                            }
                    }
                }
                .padding(.horizontal)
                .navigationBarItems(trailing: userViewModel.isLoggedIn ? logoutButton : nil)
                
                // Show a whole screen progress view while enabling the voice control
                if speechRecognizer.inProgress {
                        // Semi-transparent background to indicate loading
                        Color.black.opacity(0.3)
                            .edgesIgnoringSafeArea(.all)
                            .blur(radius: 3)

                        // Loading content
                        VStack {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(1.5)
                            Text("Enabling voice control")
                                .foregroundColor(.white)
                                .padding(.top, 20)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.5))
                        .edgesIgnoringSafeArea(.all)
                    }
                
            }
            .onAppear {
                if !userViewModel.isLoggedIn {
                    showLoginAlert = true
                }
                refresh()
            }
            .onChange(of: userViewModel.isLoggedIn, perform: { newValue in
                if newValue {
                    wantsLogin = false
                    refresh()
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
    
    func refresh() {
        profileViewPostsModel.getUserInformation()
        profileViewPostsModel.fetchPosts()
        profileViewLikedModel.getUserInformation()
        profileViewLikedModel.fetchPosts()
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
                if let url = URL(string: profileViewPostsModel.user.profileImageURL) {
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
                    Text(profileViewPostsModel.user.userName)
                        .font(.largeTitle)
                        .bold()
                    
                    NavigationLink(destination: ProfileSetttingView(profileSettingViewModel: ProfileSettingViewModel(), profileViewModel: profileViewPostsModel).navigationBarBackButtonHidden(true)) {
                        Text("Modify Profile Details")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.orange)
                            .cornerRadius(20)
                    }
                    Button(action: {
                        if speechRecognizer.isListening {
                            speechRecognizer.stopListening()
                        } else {
                            speechRecognizer.checkAndStartListening()
                        }
                    }, label: {
                        Text("Enable Voice Control: \(speechRecognizer.isListening ? "ON" : "OFF")")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.orange)
                            .cornerRadius(20)
                    })
                    .alert(isPresented: $speechRecognizer.showingPermissionAlert) {
                        Alert(
                            title: Text("Permissions Required"),
                            message: Text("This app requires access to the microphone and speech recognition. Please enable permissions in settings."),
                            primaryButton: .default(Text("Go settings"), action: openAppSettings),
                            secondaryButton: .cancel(Text("Reject"))
                        )
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
                
                if profileViewPostsModel.posts.isEmpty{
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
                    PostCollection(
                        userViewModel: userViewModel,
                        postCollectionModel: profileViewPostsModel,
                        gradientBackground: gradientBackground
                    )
                }.listStyle(.plain)
            } else if selectedTab == .liked {                
                if profileViewLikedModel.posts.isEmpty {
                    Text("💔Sorry, You don't have liked posts yet.")
                        .frame(alignment: .center)
                        .bold()
                        .font(.headline)
                        .opacity(0.8)
                        .padding(.vertical, 5)
                }
                
                List {
                    PostCollection(
                        userViewModel: userViewModel,
                        postCollectionModel: profileViewLikedModel,
                        gradientBackground: gradientBackground
                    )
                }.listStyle(.plain)
            }
            

        }
        .onChange(of: selectedTab, perform: { value in
            refresh()
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
