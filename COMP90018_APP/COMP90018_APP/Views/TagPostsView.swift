//
//  TagPostsView.swift
//  COMP90018_APP
//
//  Created by frank w on 8/11/2023.
//

import SwiftUI
import Flow

struct TagPostsView: View {
    var tag: String

    @ObservedObject var userViewModel: UserViewModel
    @StateObject var postsViewModel = PostsViewModel()
    
    let gradientBackground = LinearGradient(
        gradient: Gradient(colors: [Color.orange, Color.white]),
        startPoint: .top,
        endPoint: .bottom
    )
    
    let postGradientBackground = LinearGradient(
        gradient: Gradient(colors: [Color.orange.opacity(0.1), Color.orange.opacity(0.1)]),
        startPoint: .top,
        endPoint: .bottom
    )
    
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        ZStack{
            
            gradientBackground.edgesIgnoringSafeArea(.all)
            
            VStack{
                Text("Tag: \(tag)").bold()
                    .font(.title2)
                Text("Total Posts: \(postsViewModel.posts.count)")
                    .font(.body)
                List {
                    PostCollection(
                        userViewModel: userViewModel,
                        postCollectionModel: postsViewModel,
                        gradientBackground: postGradientBackground
                    )
                }
                .listStyle(.plain)
            }
            .padding(.horizontal, 5)
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading){
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                }
            }
        }
        .onAppear{
            postsViewModel.fetchPostsBySearch(searchCategory: tag)
        }
        
    }
}
