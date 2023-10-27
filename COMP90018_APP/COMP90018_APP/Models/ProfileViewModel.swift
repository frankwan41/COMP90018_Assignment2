//
//  ProfileViewModel.swift
//  COMP90018_APP
//
//  Created by Junran Lin on 18/9/2023.
//

import Foundation
import Firebase

class ProfileViewModel: ObservableObject{
    @Published var posts = [Post]()
    @Published var user = User(data: [:])
    @Published var likedPosts = [Post]()
   
    
    init(){
            //getUserPosts()
            //getUserInformation()
    }
    
    /**
     This function will fetch all posts of the user.
     */
    func getUserPosts(){
        
        // Confirm login status and retrieve the uid of the user
        guard let uid = Auth.auth().currentUser?.uid else{return}
        
        // Remove the current posts
        // self.posts.removeAll()
        
        
        FirebaseManager.shared.firestore
            .collection("posts")
            .whereField("useruid", isEqualTo: uid)
            .getDocuments { documentsSnapshot, error in
                if let error = error {
                    print("Failed to fetch posts of the user \(uid), \(error.localizedDescription)")
                    return
                }
                var newPosts = [Post]()
                documentsSnapshot?.documents.forEach({ snapshot in
                    let data = snapshot.data()
                    let post = Post(data: data)
                    // self.posts.append(post)
                    // self.posts.sort{ $0.timestamp > $1.timestamp}
                    
                    newPosts.append(post)
                    newPosts.sort{ $0.timestamp > $1.timestamp}
                })
                
                self.posts = newPosts
                
            }
        
        self.getUserInformation()
        
    }
    
    
    func getUserLikedPosts(){
        
        // self.likedPosts.removeAll()
        
        // Remove the posts that are not in the user liked list
        self.likedPosts.removeAll { postCurrentlyLiked in
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
                        if !self.likedPosts.contains(where: { postLiked in
                            postLiked.id == post.id
                        }){
                            self.likedPosts.append(post)
                            self.likedPosts.sort{$0.timestamp > $1.timestamp}
                        }else{
                            // If the post is currently in the likedPosts, update the post
                            if let postIndex = self.likedPosts.firstIndex(where: {$0.id == post.id}){
                                self.likedPosts[postIndex] = post
                            }
                            
                        }
                        
                    })
                    
                }
        }
        
    }
    
    
    
    /**
     This function will fetch the information of the user.
     */
    
    func getUserInformation(){
        
        // Confirm login status and retrieve the uid of the user
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        FirebaseManager.shared.firestore
            .collection("users")
            .document(uid)
            .getDocument { documentSnapshot, error in
                if let error = error{
                    print("Failed to fetch the profile of the user \(uid), \(error.localizedDescription)")
                    return
                }
                
                let data = documentSnapshot?.data()
                let user = User(data: data!)
                self.user = user
                
                self.getUserLikedPosts()
            }
        
        
    }
    
}
