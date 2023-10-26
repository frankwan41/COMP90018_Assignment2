//
//  SinglePostViewModel.swift
//  COMP90018_APP
//
//  Created by bowenfan-unimelb on 25/10/2023.
//

import Foundation
import Firebase
import FirebaseFirestore

class SinglePostViewModel: ObservableObject {
    
    func updatePostLikes(postID: String, newLikes: Int) {
        let updatedData = [
            "likes": newLikes
        ] as [String: Any]
        
        FirebaseManager.shared.firestore
            .collection("posts")
            .document(postID)
            .updateData(updatedData)
        
        print("Successfully updated the details of post \(postID).")
    }
    
    func updateCommentLikes(commentID: String, newLikes: Int) {
        let updatedData = [
            "likes": newLikes
        ] as [String: Any]
        
        FirebaseManager.shared.firestore
            .collection("comments")
            .document(commentID)
            .updateData(updatedData)
        
        print("Successfully updated the details of comment \(commentID).")
    }
    
    func removeComment(commentID: String) {
        FirebaseManager.shared.firestore
            .collection("comments")
            .document(commentID)
            .delete() { err in
                if let err = err {
                    print("Error removing comment \(err)")
                } else {
                    print("Successfully removed comment \(commentID)")
                }
            }
    }
    
    func addComment(postID: String, content: String) {
        
        // Confirm the status of login and obtain the userUID
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        FirebaseManager.shared.firestore
            .collection("posts")
            .document(postID)
            .getDocument { documentSnapshot, error in
                if let error = error{
                    print("Failed to fetch the post \(postID), \(error.localizedDescription)")
                    return
                }
                
                // Put data into comments
                let commentRef = Firestore.firestore().collection("comments").document()
                commentRef.setData([
                    "id": commentRef.documentID as String,
                    "content": content,
                    "likes": 0,
                    "userid": uid,
                ])
                
                // Add comment into post
                let data = documentSnapshot?.data()
                var post = Post(data: data!)
                let postRef = Firestore.firestore().collection("posts").document(postID)
                post.comments.append(commentRef.documentID)
                postRef.updateData([
                    "comments": post.comments
                ])
                
                print("Successfully uploaded the comment \(commentRef.documentID)")
            }
    }
    
    func getPost(postID: String, completion: @escaping (Post?) -> Void) {
        FirebaseManager.shared.firestore
            .collection("posts")
            .document(postID)
            .getDocument { documentSnapshot, error in
                if let error = error {
                    print("Unable to fetch the details of the post \(postID), \(error.localizedDescription)")
                    completion(nil)
                } else if let documentSnapshot = documentSnapshot, let data = documentSnapshot.data() {
                    let post = Post(data: data)
                    print("Successfully fetched the post \(postID)")
                    completion(post)
                } else {
                    completion(nil)
                }
        }
    }
    
    func getPostComments(postID: String, completion: @escaping ([Comment]?) -> Void) {
        FirebaseManager.shared.firestore
            .collection("posts")
            .document(postID)
            .getDocument { documentSnapshot, error in
                if let error = error {
                    print("Unable to fetch the details of the post \(postID), \(error.localizedDescription)")
                    completion(nil)
                } else if let documentSnapshot = documentSnapshot, let data = documentSnapshot.data() {
                    var comments: [Comment] = []
                    let post = Post(data: data)
                    print("Successfully fetched the post \(postID)")
                    
                    let dispatchGroup = DispatchGroup()
                    
                    for commentID in post.comments {
                        dispatchGroup.enter()
                        self.getComment(commentID: commentID) { comment in
                            if let comment = comment {
                                comments.append(comment)
                            }
                            dispatchGroup.leave()
                        }
                    }
                    
                    dispatchGroup.notify(queue: .main) {
                        completion(comments)
                    }
                } else {
                    completion(nil)
                }
        }
    }

    
    func getComment(commentID: String, completion: @escaping (Comment?) -> Void) {
        FirebaseManager.shared.firestore
            .collection("comments")
            .document(commentID)
            .getDocument { documentSnapshot, error in
                if let error = error {
                    print("Unable to fetch the details of the comment \(commentID), \(error.localizedDescription)")
                    completion(nil)
                } else if let documentSnapshot = documentSnapshot, let data = documentSnapshot.data() {
                    let comment = Comment(data: data)
                    print("Successfully fetched the comment \(commentID)")
                    completion(comment)
                } else {
                    completion(nil)
                }
        }
    }
    
}
