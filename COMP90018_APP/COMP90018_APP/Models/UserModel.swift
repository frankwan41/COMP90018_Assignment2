//
//  UserModel.swift
//  COMP90018_APP
//
//  Created by Junran Lin on 14/9/2023.
//

import Foundation
import Firebase

struct User: Decodable{
    var userName: String
    var gender: String
    var email: String
    var profileImageURL: String
    var age: String
    var phoneNumber: String
    
    init(data: [String: Any]){
        self.userName = data["username"] as? String ?? ""
        self.gender = data["gender"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.profileImageURL = data["profileimageurl"] as? String ?? ""
        self.age = data["age"] as? String ?? ""
        self.phoneNumber = data["phonenumber"] as? String ?? ""
    }
    
}

class UserViewModel: ObservableObject {
    @Published var isLoggedIn = false
    @Published var errorMessage: String = ""
    
    init() {
        isLoggedIn = FirebaseManager.shared.auth.currentUser?.uid == nil
    }
    
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
    
    func signUpUser(email: String, password: String){
        FirebaseManager.shared.auth.createUser(withEmail: email, password: password) {[self] result, error in
            if let error = error {
                print("Failed to sign up user \(error)")
                self.errorMessage = "Failed to sign up"
                return
            }
            print("Successfully signed up user \(result!.user.uid)")
            self.signInUser(email: email, password: password)
            print("After signed up: Successfully signed in as user \(result!.user.uid)")
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

