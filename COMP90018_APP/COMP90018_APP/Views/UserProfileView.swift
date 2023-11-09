//
// UserProfileView.swift
// COMP90018_APP
//
// Created by Shuyu Chen on 6/11/2023.
//

import SwiftUI
import Kingfisher

struct UserProfileView: View {
    
    @StateObject var userViewModel = UserViewModel()
    @ObservedObject var userProfileViewModel: UserProfileViewModel

    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    List {
                        PostCollection(
                            userViewModel: userViewModel,
                            postCollectionModel: userProfileViewModel
                        )
                    }
                }
                .navigationBarTitle(userProfileViewModel.username.map {
                    "\($0)'s Posts"
                } ?? "Loading...", displayMode: .inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.black)
                        }
                    }
                }
            }
        }
        .onAppear {
            userProfileViewModel.fetchPosts()
            userProfileViewModel.fetchUserProfile()
        }
    }
}
