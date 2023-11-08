//
//  PostCollection.swift
//  COMP90018_APP
//
//  Created by Bowen Fan on 27/10/2023.
//

import SwiftUI

struct PostCollection: View {

    @ObservedObject var userViewModel: UserViewModel
    @ObservedObject var postCollectionModel: PostCollectionModel
    
    var body: some View {
        ForEach($postCollectionModel.posts) { $post in
            PostCard(
                post: $post,
                userViewModel: userViewModel,
                postCollectionModel: postCollectionModel
            )
        }
        .clipShape(RoundedRectangle(cornerRadius: 25))
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
}
