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
    
    @StateObject var messageViewModel: MessageViewModel
    @StateObject var chatMainViewModel: ChatMainViewModel
    
    @AppStorage("viewDisplay") var viewSwitcher = viewPage.welcome
    
    init(currentUser: User) {
        self.currentUser = currentUser
        showActiveButton = self.currentUser.isActive
        _messageViewModel = StateObject(wrappedValue: MessageViewModel(user: nil, currentUser: currentUser))
        _chatMainViewModel = StateObject(wrappedValue: ChatMainViewModel(currentUser: currentUser))
    }
    
    var body: some View {
        NavigationView {
            VStack {
                HStack(spacing: 16) {
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
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(currentUser.userName)
                            .font(.system(size: 24))
                            .bold()
                        
                        Text(currentUser.email)
                            .font(.system(size: 12))
                            .foregroundColor(Color(.lightGray))
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
                
                NavigationLink("", destination: MessageView(viewModel: messageViewModel), isActive: $showMessageView)
            }
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
                    .font(.title2)
                    .padding(.horizontal, 10)
                    .tint(.orange)
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
                                                    {self.chatMainViewModel.setUserActiveState(state: true) { info in
                    if info != nil{
                        showActiveButton = true
                    }else{
                        showActiveButton = false
                    }
                }}
                                                        ))
            }
            .fullScreenCover(isPresented: $showNewMessageView) {
                NewMessageView { user in
                    showMessageView.toggle()
                    messageViewModel.user = user
                    messageViewModel.fetchMessages()
                }
            }
        }
    }
}
//
//#Preview {
//    ChatMainView()
//}
