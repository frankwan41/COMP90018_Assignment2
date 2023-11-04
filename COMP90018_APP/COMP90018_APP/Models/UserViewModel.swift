//
//  UserViewModel.swift
//  COMP90018_APP
//
//  Created by Junran Lin on 18/9/2023.
//

import Foundation
import Firebase
import FirebaseStorage
import UIKit

class UserViewModel: ObservableObject {
    
    @Published var isLoggedIn = false
    @Published var errorMessage = ""
    @Published var currentUser: User?
    
    init() {
        FirebaseManager.shared.auth.addStateDidChangeListener { (auth, user) in
            self.isLoggedIn = user != nil
            if self.isLoggedIn{
                self.getCurrentUser { user in
                    self.currentUser = user
                }
            }
        }
    }
    
    func getUserUID() -> String? {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            return nil
        }
        return uid
    }
    
    /**
     Inputs: email and password
     This function takes the email and the password of the user to login the authentication of Fireabse. It will return error if the process fails,
     */
    func signInUser(email: String, password: String){
        FirebaseManager.shared.auth.signIn(withEmail: email, password: password){ result, error in
            if let error = error {
                print("Failed to sign in user \(error)")
                self.errorMessage = "Invalid sign credentials!"
                return
            }
            self.isLoggedIn = true
            
            self.getCurrentUser { user in
                self.currentUser = user
            }
            print("Successfully signed in as user: \(result!.user.uid)")
            
            // Update the uid of the user
            let userData = [
                "uid": result!.user.uid,
            ] as [String: Any]
            
            FirebaseManager.shared.firestore
                .collection("users")
                .document(result!.user.uid)
                .updateData(userData)
            
            print("Successfully update the uid of user \(FirebaseManager.shared.auth.currentUser?.uid ?? "")")
            
            
        }
    }
    
    /**
     Inputs: email and password of the user as well as the image
     This function takes the email and password of the user to create an account in the firebase database and associates it with the image of the user.
     */
    func signUpUser(email: String, password: String, userName: String, gender: String, age: String, phoneNumber: String, likedPostsIDs: [String] = [], likedCommentsIDs: [String] = []){
        FirebaseManager.shared.auth.createUser(withEmail: email, password: password) {[self] result, error in
            if let error = error {
                print("Failed to sign up user \(error)")
                self.errorMessage = "Failed to sign up"
                return
            }
            print("Successfully signed up user \(result!.user.uid)")
            self.signInUser(email: email, password: password)
            print("After signed up: Successfully signed in as user \(result!.user.uid)")
            
            // Save basic information of the user
            self.saveUserTextInformation(userName: userName, gender: gender, email: email, age: age, phoneNumber: phoneNumber, likedPostsIDs: likedPostsIDs, likedCommentsIDs: likedCommentsIDs)
            
        }
    }
    
    /**
     Inputs: Basic information of user
     Save them and the uid into the collection.
     */
    func saveUserTextInformation(userName: String, gender: String, email: String, age: String, phoneNumber: String, likedPostsIDs: [String], likedCommentsIDs: [String]){
        // Check whether the user has logined
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else{
            return
        }
        
        let userData = [
            "uid": uid,
            "username": userName,
            "gender": gender,
            "email": email,
            "age": age,
            "phonenumber": phoneNumber,
            "likedpostsids": likedPostsIDs,
            "likedcommentsids": likedCommentsIDs
        ] as [String: Any]
        
        FirebaseManager.shared.firestore
            .collection("users")
            .document(uid)
            .setData(userData,merge: true)
        
        print("Successfully saved the details of user \(FirebaseManager.shared.auth.currentUser?.uid ?? "")")
    }
    
    /**
     Input: the url of image in storage
     This function saves the url to the image in the collection of user
     */
    func saveUserImageInformation(imageProfileURL: URL){
        // Confirm login status
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {return}
        
        let userData = ["profileimageurl":imageProfileURL.absoluteString]
        
        FirebaseManager.shared.firestore
            .collection("users")
            .document(uid)
            .setData(userData, merge: true)
        print("Successfully Uploaded the link to the image of user profile to the details of the user \(FirebaseManager.shared.auth.currentUser?.uid ?? "")")
    }
    
    /**
     Inputs: Image of the user
     This function takes iimage of the user and saves them to the storage of firebase
     
     */
    func saveProfileImageToStorage(image: UIImage){
        
        // Check whether the user has logined
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            return}
        
        // Create the reference of the image in storage by the uid of the user
        let ref = FirebaseManager.shared.storage.reference(withPath: uid)
        
        // Compress the image
        guard let imageData = image.jpegData(compressionQuality: 1) else{return}
        
        // Put the image data into the reference
        ref.putData(imageData, metadata: nil) { metadata, error in
            if let error = error{
                print(error)
                return
            }
            
            // Get the url of the image if it is successfully stored
            ref.downloadURL { url, error in
                if let error = error{
                    print(error)
                    return
                }
                
                // Check whether the url exists
                print(url?.absoluteString ?? "error in Uplodaing Image of the user")
                guard let url = url else{return}
                self.saveUserImageInformation(imageProfileURL: url)
            }
        }
    }
    
    func clickPostLikeButton(postID: String) {
        
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            print("Unable to get the uid of the user, check the login state.")
            return
        }
        
        getCurrentUser { user in
            if let user = user {
                var like: Bool? = nil
                var updatedUserData = [
                    "likedpostsids": user.likedPostsIDs
                ] as [String: Any]
                
                if let likedPostsIDs = updatedUserData["likedpostsids"] as? [String] {
                    if likedPostsIDs.contains(postID) {
                        // Unlike
                        updatedUserData["likedpostsids"] = likedPostsIDs.filter { $0 != postID }
                        like = false
                    } else {
                        // Like
                        var newLikedPostsIDs = likedPostsIDs
                        newLikedPostsIDs.append(postID)
                        updatedUserData["likedpostsids"] = newLikedPostsIDs
                        like = true
                    }
                }
                FirebaseManager.shared.firestore
                    .collection("users")
                    .document(uid)
                    .updateData(updatedUserData)
                print("Successfully updated liked posts of user \(uid).")
                
                self.getPost(postID: postID) { post in
                    if let post = post {
                        var updatedPostData = [
                            "likes": post.likes
                        ] as [String: Any]
                        
                        if let likes = updatedPostData["likes"] as? Int, let like = like {
                            updatedPostData["likes"] = like ? likes + 1 : likes - 1
                        }
                        FirebaseManager.shared.firestore
                            .collection("posts")
                            .document(postID)
                            .updateData(updatedPostData)
                        print("Successfully updated post \(postID).")
                    }
                }
            }
        }
        
    }
    
    func clickCommentLikeButton(commentID: String) {
        
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            print("Unable to get the uid of the user, check the login state.")
            return
        }
        
        getCurrentUser { user in
            if let user = user {
                var like: Bool? = nil
                var updatedUserData = [
                    "likedcommentsids": user.likedCommentsIDs
                ] as [String: Any]
                
                if let likedCommentsIDs = updatedUserData["likedcommentsids"] as? [String] {
                    if likedCommentsIDs.contains(commentID) {
                        // Unlike
                        updatedUserData["likedcommentsids"] = likedCommentsIDs.filter { $0 != commentID }
                        like = false
                    } else {
                        // Like
                        var newLikedCommentsIDs = likedCommentsIDs
                        newLikedCommentsIDs.append(commentID)
                        updatedUserData["likedcommentsids"] = newLikedCommentsIDs
                        like = true
                    }
                }
                FirebaseManager.shared.firestore
                    .collection("users")
                    .document(uid)
                    .updateData(updatedUserData)
                print("Successfully updated liked comments of user \(uid).")
                
                self.getComment(commentID: commentID) { comment in
                    if let comment = comment {
                        var updatedCommentData = [
                            "likes": comment.likes
                        ] as [String: Any]
                        
                        if let likes = updatedCommentData["likes"] as? Int, let like = like {
                            updatedCommentData["likes"] = like ? likes + 1 : likes - 1
                        }
                        FirebaseManager.shared.firestore
                            .collection("comments")
                            .document(commentID)
                            .updateData(updatedCommentData)
                        print("Successfully updated comment \(commentID).")
                    }
                }
            }
        }
        
    }
    
    func resetPassword(email: String) {
        FirebaseManager.shared.auth.sendPasswordReset(withEmail: email){error in
            if let error = error {
                print("Failed to reset password")
                print("Some error occured \(error)")
            }
        }
    }
    
    // TODO: Update Email function
    func updateEmail(email: String) {
    
        
       
    }
    
    func signOutUser(){
        isLoggedIn = false
        currentUser = nil
        do {
            try FirebaseManager.shared.auth.signOut()
            print("Successfully signed out")
        } catch {
            print("Error signed out: \(error)")
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
    
    func getComment(commentID: String, completion: @escaping (Comment?) -> Void) {
        FirebaseManager.shared.firestore
            .collection("comments")
            .document(commentID)
            .getDocument { documentSnapshot, error in
                if let error = error {
                    print("Failed to fetch comment \(commentID), \(error.localizedDescription)")
                    completion(nil)
                } else if let documentSnapshot = documentSnapshot, let data = documentSnapshot.data() {
                    let comment = Comment(data: data)
                    print("Successfully fetched Comment \(commentID)")
                    completion(comment)
                } else {
                    completion(nil)
                }
        }
    }
    
    func getUser(userUID: String, completion: @escaping (User?) -> Void) {
        FirebaseManager.shared.firestore
            .collection("users")
            .document(userUID)
            .getDocument { documentSnapshot, error in
                if let error = error {
                    print("Failed to fetch user \(userUID), \(error.localizedDescription)")
                    completion(nil)
                } else if let documentSnapshot = documentSnapshot, let data = documentSnapshot.data() {
                    let user = User(data: data)
                    print("Successfully fetched user \(userUID)")
                    completion(user)
                } else {
                    completion(nil)
                }
        }
    }

    func getCurrentUser(completion: @escaping (User?) -> Void) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            completion(nil)
            return
        }
        getUser(userUID: uid) { user in completion(user) }
    }
    
    func sendPasswordResetEmail(email: String, completion: @escaping (Result<Void, Error>) -> Void) {
            Auth.auth().sendPasswordReset(withEmail: email) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
}
