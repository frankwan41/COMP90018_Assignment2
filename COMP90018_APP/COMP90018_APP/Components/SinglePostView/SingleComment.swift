//
//  SingleComment.swift
//  COMP90018_APP
//
//  Created by Bowen Fan on 28/10/2023.
//

import SwiftUI
import Kingfisher

struct SingleComment: View {
    
    @Binding var post: Post
    
    @Binding var comment: Comment
    @Binding var comments: [Comment]
    
    @State private var showLoginSheet = false
    
    @State var profileImageURL: String?
    @State var authorUsername: String?
    @State var userID: String?
    
    @StateObject var userViewModel = UserViewModel()
    
    var body: some View {

        HStack(alignment: .top, spacing: 10) {
            // Front section: contains only user profile photo
            if let urlString = profileImageURL {
                let url = URL(string: urlString)
                KFImage(url)
                    .resizable()
                    .frame(maxWidth: 35, maxHeight: 35)
                    .clipped()
                    .cornerRadius(50)
                    .overlay(RoundedRectangle(cornerRadius: 44).stroke(Color(.label), lineWidth: 1))
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(maxWidth: 35, maxHeight: 35)
                    .clipped()
                    .cornerRadius(50)
                    .overlay(RoundedRectangle(cornerRadius: 44).stroke(Color(.label), lineWidth: 1))
            }
            
            // Middle section: contains username, comments, possible image comment
            VStack(alignment:.leading, spacing: 5){
                if let username = authorUsername {
                    Text(username)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Text(comment.content)
                    .padding(.bottom)
            }
            // End section: contains like button and number of likes
            Spacer() // Aligns the following UI to the right
            VStack {
                if userID == comment.userID {
                    DeleteButtonComment(
                        post: $post,
                        comments: $comments,
                        comment: $comment
                    )
                }
            }
            VStack {
                LikeButtonComment(
                    comment: $comment,
                    userViewModel: userViewModel
                )
                Text(String(comment.likes))
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
            
        }
        .onAppear {
            userID = userViewModel.getUserUID()
            userViewModel.getUser(userUID: comment.userID) { user in
                if let user = user {
                    authorUsername = user.userName
                    profileImageURL = user.profileImageURL
                } else {
                    authorUsername = nil
                    profileImageURL = nil
                }
            }
        }
    }
}
