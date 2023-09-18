//
//  UserViewModel.swift
//  COMP90018_APP
//
//  Created by Junran Lin on 18/9/2023.
//

import Foundation
import Firebase
import FirebaseStorage

class UserViewModel: ObservableObject{
    @Published var isLoggedIn = false
    @Published var errorMessage = ""
    
    init(){
        isLoggedIn = FirebaseManager.shared.auth.currentUser?.uid == nil
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
            print("Successfully signed in as user: \(result!.user.uid)")
        }
    }
    
    
    /**
     Inputs: email and password of the user as well as the image
     This function takes the email and password of the user to create an account in the firebase database and associates it with the image of the user.
     */
    func signUpUser(email: String, password: String, userName: String, gender: String, age: String, phoneNumber: String, likedPostsIDs: [String] = []){
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
    
    func updateEmail(email: String) {
        
       
    }
    
    func signOutUser(){
        isLoggedIn = false
        do{
            try FirebaseManager.shared.auth.signOut()
            print("Successfully signed out")
        }catch{
            print("Error signed out: \(error)")
        }
    }
}
