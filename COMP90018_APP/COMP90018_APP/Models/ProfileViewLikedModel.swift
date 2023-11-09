//
//  ProfileViewLikedModel.swift
//  COMP90018_APP
//
//  Created by Bowen Fan on 29/10/2023.
//

import Foundation
import Firebase

class ProfileViewLikedModel: ProfileViewModel {
    
    override func fetchPosts(){
        
        // Remove the posts that are not in the user liked list
        self.posts.removeAll { postCurrentlyLiked in
            // Check whether the post is in the liked list
            !user.likedPostsIDs.contains { postIDToUpdate in
                postIDToUpdate == postCurrentlyLiked.id
            }
        }
        
        for likedPostID in user.likedPostsIDs{
            FirebaseManager.shared.firestore
                .collection("posts")
                .whereField("id", isEqualTo: likedPostID)
                .getDocuments { documentsSnapshot, error in
                    if let error = error{
                        print("Failed to fetch the post \(likedPostID), \(error.localizedDescription)")
                        return
                    }
                    
                    documentsSnapshot?.documents.forEach({ snapshot in
                        let data = snapshot.data()
                        let post = Post(data: data)
                        
                        // If the post is not in the current likedPosts
                        if !self.posts.contains(where: { postLiked in
                            postLiked.id == post.id
                        }){
                            self.posts.append(post)
                            self.posts.sort{$0.timestamp > $1.timestamp}
                        }else{
                            // If the post is currently in the likedPosts, update the post
                            if let postIndex = self.posts.firstIndex(where: {$0.id == post.id}){
                                self.posts[postIndex] = post
                            }
                            
                        }
                        
                    })
                    
                }
        }
    }
    
}

