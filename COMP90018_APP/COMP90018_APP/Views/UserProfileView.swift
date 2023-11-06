//
//  UserProfileView.swift
//  COMP90018_APP
//
//  Created by Shuyu Chen on 6/11/2023.
//




import SwiftUI
import Kingfisher


import SwiftUI
import Kingfisher

struct UserProfileView: View {
    @ObservedObject var viewModel: UserProfileViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(viewModel.posts) { post in
                    VStack(alignment: .leading) {
                        if let imageURLString = post.imageURLs.first, let url = URL(string: imageURLString) {
                            KFImage(url)
                                .resizable()
                                .scaledToFit()
                        }
                        Text(post.postTitle)
                            .font(.title)
                            .fontWeight(.bold)
                        Text(post.content)
                        HStack {
                            // Tags view could be a reusable component if you have one, otherwise just display the text
                            ForEach(post.tags, id: \.self) { tag in
                                Text(tag)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color.gray.opacity(0.2))
                                    .clipShape(Capsule())
                            }
                        }
                        // To Do Add more post details
                    }
                    .padding()
                }
            }
        }
        .navigationBarTitle("User Profile", displayMode: .inline)
    }
}
