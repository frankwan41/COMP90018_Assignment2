//
//  WelcomView.swift
//  COMP90018_APP
//
//  Created by frank w on 14/9/2023.
//

enum viewPage: String{
    case welcome = "welcome"
    case tab = "tab"
    case shake = "shake"
    case chat = "chat"
}


import SwiftUI

struct WelcomView: View {

    @AppStorage("viewDisplay") var viewSwitcher = viewPage.welcome
    // @State private var currentUser: User?
    @StateObject private var userViewModel = UserViewModel()
    @StateObject private var locationManager = LocationManager()
    @StateObject private var chatMainViewModel: ChatMainViewModel
    
    init(){
        viewSwitcher = viewPage.welcome
        _chatMainViewModel = StateObject(wrappedValue: ChatMainViewModel(currentUser: User(data: ["":""])))
    }
    
    
    var body: some View {
        
        
        
        
        VStack{
            if viewSwitcher == viewPage.welcome{
                welcomeMainView()
            }else if viewSwitcher == viewPage.tab{
                TabMainView(userViewModel: userViewModel, chatViewModel: chatMainViewModel)
                //TODO: Change the color scheme if neccessary
                    .preferredColorScheme(.light)
                    .task {
                        userViewModel.getCurrentUser { user in
                            userViewModel.currentUser = user
                        }
                    }
            }else if viewSwitcher == viewPage.shake{
                ShakeView()
            }else if viewSwitcher == viewPage.chat{
                if let currentUser = userViewModel.currentUser{
                    ChatMainView(currentUser: currentUser, locationManager: locationManager, chatMainViewModel: chatMainViewModel)
                        .preferredColorScheme(.light)
                }else{
                    TabMainView(userViewModel: userViewModel, chatViewModel: chatMainViewModel)
                        .preferredColorScheme(.light)
                        .task {
                            userViewModel.getCurrentUser { user in
                                userViewModel.currentUser = user
                            }
                        }
                }
            }
        }
        .onChange(of: userViewModel.currentUser, perform: { newValue in
            if newValue != nil{
                chatMainViewModel.currentUser = userViewModel.currentUser ?? User(data: ["":""])
                chatMainViewModel.fetchRecentMessages()
            }else {
                chatMainViewModel.currentUser = User(data: ["":""])
            }
        })
        .task {
            userViewModel.getCurrentUser { user in
                userViewModel.currentUser = user
                if let user = user {
                    chatMainViewModel.currentUser = user
                    chatMainViewModel.fetchRecentMessages()
                }
            }
        }
    }
    
}

struct welcomeMainView: View {
    
    @AppStorage("viewDisplay") var viewSwitcher = viewPage.welcome
    @AppStorage("shakeResult") var shakeResult = ""
    
    @State private var isAnimating = false
    
    var body: some View{
        ZStack {
            Image("welcomeBackground")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 80){
                Text("🩷Do you know🩷\nwhat to eat today?")
                    .font(.custom("ChalkboardSE-Bold", size: 30))
                    .multilineTextAlignment(.center)
                    .bold()
                Text("🌭🍔🍟🍕🥪\n🥙🧆🌮🌯🫔\n🥗🥘🫕🍝🍜")
                    .multilineTextAlignment(.center)
                    .font(.largeTitle)
                    .padding(.horizontal)
                HStack(spacing: 100){
                    
                    Button {
                        // Navigate to posts view
                        viewSwitcher = viewPage.tab
                        shakeResult = ""
                    } label: {
                        Text("YES")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 100, height: 50)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.green))
                    }
                    .scaleEffect(isAnimating ? 1.8 : 1.0) // Apply the scale effect
                    
                    .onAppear {
                        withAnimation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                            isAnimating = true
                        }
                        
                    }
                    
                    
                    Button {
                        // Navigate to shake view for pick random restaurant
                        viewSwitcher = viewPage.shake
                    } label: {
                        Text("NO")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 100, height: 50)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.red))
                    }
                    .scaleEffect(isAnimating ? 1.8 : 1.0) // Apply the scale effect
                    
                    .onAppear {
                        withAnimation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                            isAnimating = true
                        }
                        
                    }
                }
            }
            .offset(x: -35, y: 40)
        }.ignoresSafeArea()
            .withFooter()
    }
}

struct WelcomView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack{
            WelcomView()
        }
    }
}
