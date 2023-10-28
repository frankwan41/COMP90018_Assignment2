//
//  CommentSection.swift
//  COMP90018_APP
//
//  Created by Bowen Fan on 28/10/2023.
//

import SwiftUI

struct CommentsSection: View {
    
    @Binding var post: Post
    @Binding var comments: [Comment]
    
    var body: some View {
        VStack(alignment:.leading){
            HStack{
                Text("\(comments.count) Comments")
                    .font(.headline)
                    .fontWeight(.thin)
                    .padding(.horizontal)
                Spacer()
            }.padding(.bottom)
            
            if comments.count > 0 {
                ForEach($comments, id: \.commentID) { comment in
                    SingleComment(post: $post, comment: comment, comments: $comments).padding()
                    Divider()
                }
            }
        }
    }
}
