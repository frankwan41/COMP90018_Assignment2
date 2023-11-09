//
//  SingleComment.swift
//  COMP90018_APP
//
//  Created by Bowen Fan on 28/10/2023.
//

import SwiftUI
import Kingfisher
import SwipeActions

struct SingleComment: View {
    
    @Binding var post: Post
    
    @Binding var comment: Comment
    @Binding var comments: [Comment]
    
    @State private var showLoginSheet = false
    
    @State var profileImageURL: String?
    @State var authorUsername: String?
    @State var userID: String?
    @State private var showDeleteCommentAlert = false
    
    @StateObject var userViewModel = UserViewModel()
    @StateObject var singlePostViewModel = SinglePostViewModel()
    
    private let dateFormatter = DateFormatter()
    @State var dateTimeText: String = ""
    
    var body: some View {
        
        SwipeView{
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
                    Text(dateTimeText)
                        .foregroundColor(.gray)
                        .font(.system(size: 12))
                }
                // End section: contains like button and number of likes
                Spacer() // Aligns the following UI to the right
                //                VStack {
                //                    if userID == comment.userID {
                //                        DeleteButtonComment(
                //                            post: $post,
                //                            comments: $comments,
                //                            comment: $comment
                //                        )
                //                    }
                //                }
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
            .contentShape(Rectangle())
        } trailingActions: { context in
            SwipeAction(systemImage: "trash", backgroundColor: .red) {
                context.state.wrappedValue = .closed
                showDeleteCommentAlert = true
            }
            .clipShape(Circle())
            .foregroundStyle(.white)
        }
        .closeOnLabelTap(true)
        .swipeEnabled(userID == comment.userID)
        
        .onAppear {
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            dateTimeText = dateFormatter.string(from: comment.timestamp)
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
        .alert(isPresented: $showDeleteCommentAlert) {
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
