//
//  PostsViewModel.swift
//  COMP90018_APP
//
//  Created by Junran Lin on 18/9/2023.
//

import Foundation
import UIKit

class PostsViewModel: PostCollectionModel {
    
    static let DEFAULT_POST_COUNT = 100
    static let MAX_IMAGE_SIZE: Int = 10 * 1024 * 1024
    
    /**
     Fetch all posts and order them by timestamps descendingly
     */
    override func fetchPosts() {
        FirebaseManager.shared.firestore
            .collection("posts")
            .order(by: "timestamp", descending: true)
            .getDocuments { documentsSnapshot, error in
                if let error = error{
                    print("Failed to fetch posts in PostsViewModel \(error)")
                    return
                }
                var newPosts = [Post]()
                documentsSnapshot?.documents.forEach { snapshot in
                    let data = snapshot.data()
                    let post = Post(data: data)
                    newPosts.append(post)
                }
                self.posts = newPosts
            }
    }
    
    /**
     Fetch all posts that contain a tag and order them by timestamps descendingly
     */
    func fetchPosts(tag: String) {
        FirebaseManager.shared.firestore
            .collection("posts")
            .whereField("tags", arrayContains: tag)
            .getDocuments { documentsSnapshot, error in
                if let error = error{
                    print("Failed to fetch posts in PostsViewModel \(error)")
                    return
                }
                var newPosts = [Post]()
                documentsSnapshot?.documents.forEach { snapshot in
                    let data = snapshot.data()
                    let post = Post(data: data)
                    newPosts.append(post)
                }
                newPosts.sort { $0.timestamp > $1.timestamp }
                self.posts = newPosts
                print(self.posts)
            }
    }
    
    /**
     Fetch a number of posts and order them by timestamps descendingly
     */
    func fetchPosts(postCount: Int) {
        FirebaseManager.shared.firestore
            .collection("posts")
            .order(by: "timestamp", descending: true)
            .limit(to: postCount)
            .getDocuments { documentsSnapshot, error in
                if let error = error{
                    print("Failed to fetch posts in PostsViewModel \(error)")
                    return
                }
                var newPosts = [Post]()
                documentsSnapshot?.documents.forEach { snapshot in
                    let data = snapshot.data()
                    let post = Post(data: data)
                    newPosts.append(post)
                }
                self.posts = newPosts
            }
    }
    
    /**
     Inputs: userUID
     This function will retrieve the image of user profile.
     */
    func getUserProfileImage(userUID: String, completion: @escaping (UIImage?) -> Void){
        let ref = FirebaseManager.shared.storage.reference(withPath: userUID)
        ref.getData(maxSize: Int64(PostsViewModel.MAX_IMAGE_SIZE)) { data, error in
            if let error = error{
                print("Unable to retrieve the image in the user profile, \(error.localizedDescription)")
                completion(nil)
            } else {
                if let data = data{
                    let image = UIImage(data: data)
                    completion(image)
                }
            }
        }
        
        
    }
    
}
