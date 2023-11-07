//
// UserProfileView.swift
// COMP90018_APP
//
// Created by Shuyu Chen on 6/11/2023.
//

import SwiftUI
import Kingfisher

struct UserProfileView: View {
    @ObservedObject var viewModel: UserProfileViewModel
    @State private var selectedPost: Post?

    @Environment(\.dismiss) var dismiss
    
    // Define the gradient background
    let gradientBackground = LinearGradient(
        gradient: Gradient(colors: [Color.orange.opacity(0.1), Color.orange.opacity(0.1)]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(viewModel.posts) { post in
                            Button(action: {
                                self.selectedPost = post
                            }) {
                                PostCard(
                                    post: .constant(post),
                                    userViewModel: viewModel.userViewModel,
                                    postCollectionModel: viewModel.postCollectionModel
                                )
                                .background(gradientBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 25))
                                .padding(.horizontal)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
            .navigationBarTitle(viewModel.username.map { "\($0)'s Profile" } ?? "User Profile", displayMode: .inline)
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
            .sheet(item: $selectedPost) { selectedPost in
                SinglePostView(post: .constant(selectedPost))
            }
        }
        .background(Color.white) // Set the background color for the entire view to white
    }
}
