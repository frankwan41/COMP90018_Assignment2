//
//  LikeButton.swift
//  COMP90018_APP
//
//  Created by Bowen Fan on 27/10/2023.
//

import SwiftUI

struct LikeButton: View {
    
    let width: CGFloat // 30 in SinglePostView, 20 in PostCard
    let height: CGFloat // 25 in SinglePostView, 20 in PostCard
    
    @Binding var post: Post
    @ObservedObject var userViewModel: UserViewModel
    
    @State var isLiked: Bool = false
    
    @State private var heartScale: CGFloat = 1.0
    @State private var showLoginAlert = false
    
    static var DEFAULT_HEART_SCALE: CGFloat = 1.0
    static var ENLARGED_HEART_SCALE: CGFloat = 1.5
    
    var body: some View {
        Button {
            if !userViewModel.isLoggedIn {
                showLoginAlert = true
            } else {
                toggleAnimation()
                toggleLikes()
            }
        } label: {
            Image(systemName: isLiked ? "heart.fill" : "heart")
                .resizable()
                .frame(width: width, height: height)
                .scaleEffect(heartScale)
                .foregroundColor(isLiked ? .red : .black)
                .padding(.vertical)
        }
        .alert(isPresented: $showLoginAlert) {
            Alert(
                title: Text("Login Required"),
                message: Text("You need to be logged in to like."),
                dismissButton: .default(Text("OK"))
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            userViewModel.getCurrentUser { user in
                if let user = user {
                    isLiked = user.likedPostsIDs.contains(post.id)
                }
            }
        }
    }
    
    func toggleAnimation() {
        withAnimation {
            // Slightly increase the size for a moment
            heartScale = LikeButton.ENLARGED_HEART_SCALE
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            withAnimation {
                // Return to normal size
                heartScale = LikeButton.DEFAULT_HEART_SCALE
            }
        }
    }
    
    func toggleLikes() {
        userViewModel.getCurrentUser { user in
            if let user = user {
                isLiked.toggle()
                if isLiked {
                    post.likes += 1
                } else {
                    post.likes -= 1
                }
            }
        }
        userViewModel.clickPostLikeButton(postID: post.id)
    }
    
}
