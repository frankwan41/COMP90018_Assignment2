//
//  PostsViewModel.swift
//  COMP90018_APP
//
//  Created by Junran Lin on 18/9/2023.
//

import Foundation
import UIKit

class PostsViewModel: ObservableObject{
    // Key Component for saving the posts
    @Published var posts = [Post]()
    
    let defaultPostsNumber = 100
    let maxSizeOfImage: Int = 10 * 1024 * 1024
    
    init(){
        // fetch a number of posts when the model is initialized
        fetchNPosts(number: defaultPostsNumber)
        
    }
    
    /**
     This function will fetch all posts from the firebase and order them by the timestamp descendingly
     */
    func fetchAllPosts(){
        
        // Remove all existing posts
        self.posts.removeAll()
        
        
        FirebaseManager.shared.firestore
            .collection("posts")
            .getDocuments { documentsSnapshot, error in
                if let error = error{
                    print("Failed to fetch all posts \(error)")
                    return
                }
                
                documentsSnapshot?.documents.forEach({ snapshot in
                    let data = snapshot.data()
                    let post = Post(data: data)
                    self.posts.append(post)
                    self.posts.sort{$0.timestamp > $1.timestamp}
                })
            }
        
    }
    
    /**
     Inputs: userUID
     This function will retrieve the image of user profile.
     */
    func getUserProfileImage(userUID: String, completion: @escaping (UIImage?) -> Void){
        let ref = FirebaseManager.shared.storage.reference(withPath: userUID)
        ref.getData(maxSize: Int64(maxSizeOfImage)) { data, error in
            
            if let error = error{
                print("Unable to retrieve the image in the user profile, \(error.localizedDescription)")
                completion(nil)
            }else{
                if let data = data{
                    let image = UIImage(data: data)
                    completion(image)
                }
            }
        }
        
        
    }
    
    /**
     Input: the number of posts to be fetched
     This function will return the first specific number of posts and order them by the timestamp descendingly
     */
    func fetchNPosts(number: Int){
        
        
        // Remove all existing posts
        self.posts.removeAll()
        
        
        
        FirebaseManager.shared.firestore
            .collection("posts")
            .order(by: "timestamp", descending: true)
            .limit(to: number)
            .getDocuments { documentsSnapshot, error in
                
                if let error = error {
                    print("failed to fetch the first \(number) posts \(error)")
                    return
                }
                
                documentsSnapshot?.documents.forEach({ snapshot in
                    let data = snapshot.data()
                    let post = Post(data:data)
                    self.posts.append(post)
                    // self.posts.sort { $0.timestamp > $1.timestamp }
                })
            }
        
    }
    
}
