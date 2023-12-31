//
//  PostCard.swift
//  COMP90018_APP
//
//  Created by Bowen Fan on 27/10/2023.
//

import SwiftUI
import Kingfisher

struct PostCard: View {
    
    @Binding var post: Post
    @State var author: User? = nil
    @State var user: User? = nil
    @State private var showDeletePostAlert = false
    
    @ObservedObject var userViewModel: UserViewModel
    @ObservedObject var postCollectionModel: PostCollectionModel
    
    let gradientBackground = LinearGradient(
        gradient: Gradient(colors: [primaryColor, secondaryColor]),
        startPoint: .top,
        endPoint: .bottom
    )
    
    var body: some View {
        ZStack {
            gradientBackground.edgesIgnoringSafeArea(.all)
            VStack(spacing: 10){
                if let urlString = post.imageURLs.first {
                    if urlString.isEmpty {
                        ProgressView("Loading...")
                            .controlSize(.large)
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 300, height: 200, alignment: .center)
                            .tint(.orange)
                    } else {
                        let url = URL(string: urlString)
                        KFImage(url)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .font(.largeTitle)
                            .frame(maxWidth: 600, maxHeight: 400)
                    }
                }
                VStack(alignment: .leading){
                    Text(post.postTitle)
                        .font(.headline)
                        .lineLimit(2)
                        .truncationMode(.tail)
                    HStack(spacing: 4){
                        if let urlString = author?.profileImageURL {
                            let url = URL(string: urlString)
                            KFImage(url)
                                .resizable()
                                .frame(maxWidth: 30, maxHeight: 30)
                                .clipped()
                                .cornerRadius(50)
                                .overlay(RoundedRectangle(cornerRadius: 44).stroke(Color(.label), lineWidth: 1))
                        } else {
                            Image(systemName: "person.circle")
                                .resizable()
                                .frame(maxWidth: 30, maxHeight: 30)
                                .clipped()
                                .cornerRadius(50)
                                .overlay(RoundedRectangle(cornerRadius: 44).stroke(Color(.label), lineWidth: 1))
                        }
                        Text(post.userName).font(.subheadline)
                        Spacer()
                            // Alert needs to be here to not suppress LikeButton alert
                            .alert(isPresented: $showDeletePostAlert) {
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
                        LikeButtonPost(
                            width: 20,
                            height: 20,
                            post: $post,
                            userViewModel: userViewModel
                        )
                        Text(String(post.likes)).font(.subheadline)
                    }
                }
            }
            .padding()
            NavigationLink(destination: SinglePostView(post: $post).navigationBarBackButtonHidden(true)) {
                EmptyView()
            }
            .opacity(0)  // Making the NavigationLink invisible
            .allowsHitTesting(false)
        }
        .swipeActions{
            if let user = user {
                if  post.userUID == user.uid {
                    Button(role: .none) {
                        withAnimation {
                            showDeletePostAlert = true
                        }
                    } label: {
                        Image(systemName: "trash")
                    }
                    .tint(.red)
                }
            }
        }
        .task {
            postCollectionModel.getPost(postID: post.id) { post in
                if let post = post {
                    self.post = post;
                }
            }
            userViewModel.getUser(userUID: post.userUID) { user in
                if let user = user {
                    self.author = user
                }
            }
            userViewModel.getCurrentUser { user in
                if let user = user {
                    self.user = user
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
}
