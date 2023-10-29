//
//  ProfileViewPostsModel.swift
//  COMP90018_APP
//
//  Created by Bowen Fan on 29/10/2023.
//

import Foundation
import Firebase

class ProfileViewPostsModel: ProfileViewModel {
    
    override func fetchPosts(){
        
        // Confirm login status and retrieve the uid of the user
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        FirebaseManager.shared.firestore
            .collection("posts")
            .whereField("useruid", isEqualTo: uid)
            .getDocuments { documentsSnapshot, error in
                if let error = error {
                    print("Failed to fetch posts of the user \(uid), \(error.localizedDescription)")
                    return
                }
                var newPosts = [Post]()
                documentsSnapshot?.documents.forEach { snapshot in
                    let data = snapshot.data()
                    let post = Post(data: data)
                    newPosts.append(post)
                }
                newPosts.sort{ $0.timestamp > $1.timestamp}
                self.posts = newPosts
            }
        
        self.getUserInformation()
        
    }
    
}

