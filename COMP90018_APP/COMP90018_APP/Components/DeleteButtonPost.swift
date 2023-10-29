//
//  DeleteButtonPost.swift
//  COMP90018_APP
//
//  Created by Bowen Fan on 28/10/2023.
//

import SwiftUI

struct DeleteButtonPost: View {
    
    let width: CGFloat // 20 in PostCard
    let height: CGFloat // 20 in PostCard
    
    @Binding var post: Post
    @ObservedObject var userViewModel: UserViewModel
    @ObservedObject var postCollectionModel : PostCollectionModel
    
    @State private var scale: CGFloat = DEFAULT_SCALE
    @State private var showAlert = false
    
    static var DEFAULT_SCALE: CGFloat = 1.0
    static var ENLARGED_SCALE: CGFloat = 1.5
    
    var body: some View {
        Button {
            withAnimation {
                // Slightly increase the size for a moment
                scale = DeleteButtonPost.ENLARGED_SCALE
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                withAnimation {
                    scale = DeleteButtonPost.DEFAULT_SCALE // Return to normal size
                }
            }
            showAlert = true
        } label: {
            Image(systemName: "trash")
                .resizable()
                .frame(width: width, height: height)
                .scaleEffect(scale)
                .foregroundColor(.black)
                .padding(.vertical)
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Delete Confirmation"),
                message: Text("Are you sure you want to delete this post?"),
                primaryButton: .destructive(Text("Delete"), action: {
                    postCollectionModel.removePost(postID: post.id)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        postCollectionModel.fetchPosts()
                    }
                }),
                secondaryButton: .cancel()
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
}
