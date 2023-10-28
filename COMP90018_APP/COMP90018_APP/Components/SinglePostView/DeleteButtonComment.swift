//
//  DeleteButtonComment.swift
//  COMP90018_APP
//
//  Created by Bowen Fan on 28/10/2023.
//

import SwiftUI

struct DeleteButtonComment: View {
    
    @Binding var post: Post
    @Binding var comments: [Comment]
    
    @Binding var comment: Comment

    @State var deleteScale: CGFloat = 1.0
    @State var showAlert: Bool = false
    
    @StateObject var singlePostViewModel = SinglePostViewModel()
    
    var body: some View {
        Button {
            withAnimation {
                // Slightly increase the size for a moment
                deleteScale = 1.5
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                withAnimation {
                    deleteScale = 1.0 // Return to normal size
                }
            }
            showAlert = true
        } label: {
            Image(systemName: "trash")
                .scaleEffect(deleteScale)
                .foregroundColor(.gray)
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Delete Confirmation"),
                message: Text("Are you sure you want to delete this comment?"),
                primaryButton: .destructive(Text("Delete"), action: {
                    singlePostViewModel.removeComment(commentID: comment.commentID)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        singlePostViewModel.getPostComments(postID: post.id) { comments in
                            if let fetchedComments = comments {
                                self.comments = fetchedComments
                            }
                        }
                    }
                }),
                secondaryButton: .cancel()
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
}
