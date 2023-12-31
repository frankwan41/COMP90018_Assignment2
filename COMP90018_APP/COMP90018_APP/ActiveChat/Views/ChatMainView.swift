//
//  ChatMainView.swift
//  COMP90018_APP
//
//  Created by Junran Lin on 28/10/2023.
//

import SwiftUI
import Kingfisher

struct ChatMainView: View {
    
    var currentUser: User
    
    @State private var showActivateConfirmation = false
    @State private var showNewMessageView = false
    @State private var showMessageView = false
    @State private var showActiveButton = false
    @State private var showLocationRequestAlert: Bool = false
    
    @StateObject var messageViewModel: MessageViewModel
    @ObservedObject var chatMainViewModel: ChatMainViewModel
    @ObservedObject var locationManager : LocationManager
    @StateObject var userProfileViewModel: UserProfileViewModel
    
    @State var showUserProfile: Bool = false
    
    
    @AppStorage("viewDisplay") var viewSwitcher = viewPage.welcome
    
    init(currentUser: User, locationManager: LocationManager, chatMainViewModel: ChatMainViewModel) {
        self.currentUser = currentUser
        showActiveButton = self.currentUser.isActive
        
        _messageViewModel = StateObject(wrappedValue: MessageViewModel(user: nil, currentUser: currentUser))
        _chatMainViewModel = ObservedObject(wrappedValue: chatMainViewModel)
        _locationManager = ObservedObject(wrappedValue: locationManager)
        _userProfileViewModel = StateObject(wrappedValue: UserProfileViewModel(userId: currentUser.uid))
    }
    
    var body: some View {
        NavigationView {
            VStack {
                HStack(spacing: 16) {
                    
                    Button {
                        showUserProfile.toggle()
                    } label: {
                        if currentUser.profileImageURL.isEmpty{
                            
                            Image("person.circle")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipped()
                                .cornerRadius(50)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 44)
                                        .stroke(Color(.label), lineWidth: 1)
                                )
                                .shadow(radius: 5)
                            
                        }else{
                            KFImage(URL(string: currentUser.profileImageURL))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipped()
                                .cornerRadius(50)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 44)
                                        .stroke(Color(.label), lineWidth: 1)
                                )
                                .shadow(radius: 5)
                        }
                    }

                    
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(currentUser.userName)
                            .font(.system(size: 24))
                            .bold()
                            .foregroundColor(Color.orange)
                        
                        Text(currentUser.email)
                            .font(.system(size: 12))
                            .foregroundColor(Color(.lightGray))
                            .tint(Color.orange)
                    }
                    
                    Spacer()
                }
                .padding()
                
                Divider()
                
                ScrollView {
                    ForEach(chatMainViewModel.latestMessages) { message in
                        Button {
                            showMessageView.toggle()
                            
                            Task {
                                await messageViewModel.fetchUser(uid: currentUser.uid == message.fromUid ? message.toUid : message.fromUid)
                            }
                        } label: {
                            LatestMessageCompo(latestMessage: message)
                        }
                    }
                }
                
                //NavigationLink("", destination: MessageView(viewModel: messageViewModel), isActive: $showMessageView)
            }
            .fullScreenCover(isPresented: $showUserProfile, content: {
                UserProfileView(userProfileViewModel: userProfileViewModel)
            })
            .withFooter()
            .fullScreenCover(isPresented: $showMessageView, onDismiss: {
                showMessageView = false
            }, content: {
                MessageView(viewModel: messageViewModel)
            })
            
            .toolbar {
                ToolbarItem(placement:.topBarLeading){
                    Button {
                        viewSwitcher = viewPage.tab
                    } label: {
                        Image(systemName: "arrowshape.turn.up.left.circle.fill")
                            .tint(.orange)
                            .font(.title)
                    }

                }
                
                
                ToolbarItem(placement: .topBarTrailing) {
                    Toggle(showActiveButton ? "Be Inactive" : "Be Active", isOn: Binding<Bool>(
                        get: {
                            showActiveButton
                        }, set: { newValue in
                            
                            if newValue{
                                // Be active
                                showActivateConfirmation = true
                                
                               
                            }else{
                                self.chatMainViewModel.setUserActiveState(state: false) { info in
                                    if info != nil{
                                        showActiveButton = newValue
                                    }else{
                                        showActiveButton = true
                                    }
                                }
                            }
                            
                            
                        }
                    ))
                    .font(.custom("ChalkboardSE-Bold", size: 20))
                    .padding(.horizontal, 10)
                    .tint(.orange)
                    .alert(isPresented: $showLocationRequestAlert) {
                        Alert(
                            title: Text("Location Permission Denied"),
                            message: Text("The App requires location permission"),
                            primaryButton: .default(Text("Go Settings"), action: openAppSettings),
                            secondaryButton: .cancel(Text("Reject"))
                        )
                    }
                }
                if showActiveButton{
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showNewMessageView.toggle()
                        } label: {
                            Image(systemName: "plus")
                        }
                        .font(.title2)
                        .tint(.orange)
                    }
                }
                
                
            }
            .alert(isPresented: $showActivateConfirmation) {
                Alert(title: Text("Are you sure to be active?\nYour current Location will be used."),
                      primaryButton: .cancel(),
                      secondaryButton: .destructive(Text("Be Active"), 
                                                    action:
                                                    {
                    // Request location
                    requestAndUpdateLocationForBeingActive()
                    
                    }
                                                        ))
            }
            .fullScreenCover(isPresented: $showNewMessageView) {
                NewMessageView { user in
                    showMessageView.toggle()
                    messageViewModel.user = user
                    messageViewModel.fetchMessages()
                }
            }
            .onAppear{
                if showActiveButton{
                    locationManager.requestPermission { authorized in
                        if authorized{
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                                // Update the current location of the user
                                if let location = locationManager.location{
                                    
                                    
                                    self.chatMainViewModel.updateUserCurrentLocation(latitude: location.latitude, longitude: location.longitude) { result in
                                        if result == nil{
                                            // Unable to update the location
                                            self.chatMainViewModel.setUserActiveState(state: false) { result in
                                                if result == nil{
                                                    // Uable to update Active State
                                                    showActiveButton = true
                                                }else{
                                                    showActiveButton = false
                                                }
                                            }
                                            
                                        }else{
                                            // The location has been updated
                                            
                                            
                                            showActiveButton = true
                                            
                                        }
                                    }
                                    
                                }else{
                                    // Unable to obtain the location of the user
                                    self.chatMainViewModel.setUserActiveState(state: false) { result in
                                        if result == nil{
                                            // Uable to update Active State
                                            showActiveButton = true
                                        }else{
                                            showActiveButton = false
                                        }
                                    }
                                    
                                }
                            }
                        }else{
                            // Unable to update the location of the user
                            self.chatMainViewModel.setUserActiveState(state: false) { result in
                                if result == nil{
                                    // Uable to update Active State
                                    showActiveButton = true
                                    showLocationRequestAlert = true
                                }else{
                                    showActiveButton = false
                                }
                            }
                            
                            
                            
                        }
                    }
                    
                    
                }
            }
        }
        
        
    }
    
    private func requestAndUpdateLocationForBeingActive(){
        // Request location
        locationManager.requestPermission { authorized in
            if authorized{
                // Update the current location of the user
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                    if let location = locationManager.location{
                        

                        self.chatMainViewModel.updateUserCurrentLocation(latitude: location.latitude, longitude: location.longitude) { result in
                            if result == nil{
                                showActiveButton = false
                            }else{
                                // Update the active state of the user
                                self.chatMainViewModel.setUserActiveState(state: true) { info in
                                if info != nil{
                                    showActiveButton = true
                                }else{
                                    showActiveButton = false
                                }
                            }
                                
                            }
                        }
                        
                    }else{
                        // Unable to update the location of the user
                        showActiveButton = false
                    }
                }
            }else{
                // Unable to update the location of the user
                showLocationRequestAlert = true
                showActiveButton = false
                
            }
        }
    }
}
