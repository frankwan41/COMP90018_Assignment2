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
    
    
    
    init(){
        // Obtain the posts and information of the user
        getUserPosts()
        getUserInformation()
    }
    
    /**
     This function will fetch all posts of the user.
     */
    func getUserPosts(){
        
        // Confirm login status and retrieve the uid of the user
        guard let uid = Auth.auth().currentUser?.uid else{return}
        
        // Remove the current posts
        self.posts.removeAll()
        
        FirebaseManager.shared.firestore
            .collection("posts")
            .whereField("useruid", isEqualTo: uid)
            .getDocuments { documentsSnapshot, error in
                if let error = error {
                    print("Failed to fetch posts of the user \(uid), \(error.localizedDescription)")
                    return
                }
                
                documentsSnapshot?.documents.forEach({ snapshot in
                    let data = snapshot.data()
                    let post = Post(data: data)
                    self.posts.append(post)
                    self.posts.sort{ $0.timestamp > $1.timestamp}
                })
                
                
                
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
            }
    }
    
}