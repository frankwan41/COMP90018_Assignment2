import SwiftUI
import Kingfisher

struct ProfileView: View {

    @StateObject var userViewModel = UserViewModel()
    @StateObject var profileViewModel = ProfileViewModel()
    @State private var showLoginAlert = false
    @State private var wantsLogin = false

    var body: some View {
        let gradientStart = Color.orange.opacity(0.5)
        let gradientEnd = Color.orange
        let gradientBackground = LinearGradient(gradient: Gradient(colors: [gradientStart, gradientEnd]), startPoint: .top, endPoint: .bottom)

        NavigationView {
            ZStack {
                gradientBackground.edgesIgnoringSafeArea(.all)

                VStack(spacing: 20) {
                    if !userViewModel.isLoggedIn {
                        guestView
                    } else {
                        loggedInView
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
            if let url = URL(string: profileViewModel.user.profileImageURL) {
                KFImage(url)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
                    .shadow(radius: 10)
            } else {
                ProgressView()
            }

            Text(profileViewModel.user.userName)
                .font(.largeTitle)
                .bold()

            Text(profileViewModel.user.email)
                .font(.subheadline)

            Text(profileViewModel.user.phoneNumber)
                .font(.subheadline)

            NavigationLink(destination: ProfileSetttingView(profileSettingViewModel: ProfileSettingViewModel())) {
                Text("View Profile Settings")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.orange)
                    .cornerRadius(10)
            }
        }
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

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
