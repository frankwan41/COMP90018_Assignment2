//
//  PostCollectionModel.swift
//  COMP90018_APP
//
//  Created by Bowen Fan on 27/10/2023.
//

import Foundation

class PostCollectionModel: ObservableObject {
    
    @Published var posts = [Post]()
    
    func fetchPosts() {}
    
    func removePost(postID: String) {
        FirebaseManager.shared.firestore
            .collection("posts")
            .document(postID)
            .delete() { err in
                if let err = err {
                    print("Failed to remove post \(err)")
                } else {
                    print("Successfully removed post \(postID)")
                }
            }
    }
    
    func getPost(postID: String, completion: @escaping (Post?) -> Void) {
        FirebaseManager.shared.firestore
            .collection("posts")
            .document(postID)
            .getDocument { documentSnapshot, error in
                if let error = error {
                    print("Failed to fetch post \(postID), \(error.localizedDescription)")
                    completion(nil)
                } else if let documentSnapshot = documentSnapshot, let data = documentSnapshot.data() {
                    let post = Post(data: data)
                    print("Successfully fetched post \(postID)")
                    completion(post)
                } else {
                    completion(nil)
                }
        }
    }
    
}
