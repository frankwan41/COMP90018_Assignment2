//
//  ProfileView.swift
//  COMP90018_APP
//
//  Created by frank w on 14/9/2023.
//

import SwiftUI

struct ProfileView: View {
    
    @ObservedObject var userViewModel = UserViewModel()
    @State private var showLoginAlert = false
    @State private var wantsLogin = false
    

    
    var body: some View {
        NavigationView{
            VStack(spacing: 20){
                Text("This is the profile view")
                NavigationLink {
                    
                    ProfileSetttingView(profileSettingViewModel: ProfileSettingViewModel())
                } label: {
                    Text("Found out user profile page")
                }
                NavigationLink {
                    // SignView(userViewModel: userViewModel)
                } label: {
                    Text("Click here to signin/singup")
                }
                .alert(isPresented: $showLoginAlert) {
                    Alert(
                        title: Text("Alert"),
                        message: Text("Please log in or sign up"),
                        primaryButton: .default(Text("Sign in")) {
                            wantsLogin = true
                        },
                        secondaryButton: .cancel(Text("Cancel")) {
                            wantsLogin = false
                        }
                    )
                }
                
            }
            .onAppear {
                if !userViewModel.isLoggedIn {
                    showLoginAlert = true
                }
            }
            .onChange(of: userViewModel.isLoggedIn, perform: { newValue in
                if newValue {
                    wantsLogin = false
                }
            })
            .sheet(isPresented: $wantsLogin) {
                SignView(userViewModel: userViewModel)
                    .onDisappear{
                        if !userViewModel.isLoggedIn{
                            showLoginAlert = true
                        }
                        wantsLogin = false
                    }
                    
            }
            
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack{
            ProfileView()
        }
    }
}
