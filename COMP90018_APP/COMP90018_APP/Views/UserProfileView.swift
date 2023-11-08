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

    @Environment(\.dismiss) var dismiss
    
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
                    "\($0)'s Profile"
                } ?? "User Profile", displayMode: .inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "arrowshape.turn.up.left.circle.fill")
                                .tint(.orange)
                                .font(.title)
                                .padding(.horizontal)
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
