//
//  LikeButtonComment.swift
//  COMP90018_APP
//
//  Created by Bowen Fan on 27/10/2023.
//

import SwiftUI

struct LikeButtonComment: View {
    
    @Binding var comment: Comment
    @ObservedObject var userViewModel: UserViewModel
    
    @State var isLiked: Bool = false
    
    @State private var scale: CGFloat = DEFAULT_SCALE
    @State private var showLoginAlert = false
    
    static var DEFAULT_SCALE: CGFloat = 1.0
    static var ENLARGED_SCALE: CGFloat = 1.5
    
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
                .scaleEffect(scale)
                .foregroundColor(isLiked ? .red : .black)
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
                    isLiked = user.likedCommentsIDs.contains(comment.commentID)
                }
            }
        }
        .onChange(of: userViewModel.isLoggedIn, perform: { loggedIn in
            if (!loggedIn) {
                isLiked = false;
            }
        })
    }
    
    func toggleAnimation() {
        withAnimation {
            // Slightly increase the size for a moment
            scale = LikeButtonComment.ENLARGED_SCALE
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            withAnimation {
                // Return to normal size
                scale = LikeButtonComment.DEFAULT_SCALE
            }
        }
    }
    
    func toggleLikes() {
        isLiked.toggle()
        comment.likes = isLiked ? comment.likes + 1 : comment.likes - 1
        userViewModel.clickCommentLikeButton(commentID: comment.commentID)
    }
    
}
