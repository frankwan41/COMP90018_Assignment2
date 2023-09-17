//
//  LoginViewModel.swift
//  COMP90018_APP
//
//  Created by Junran Lin on 16/9/2023.
//

import Foundation
import Firebase
import FirebaseStorage

class LoginViewModel: ObservableObject{
    @Published var isCurrentlyLoggedOut = false
    
    init(){
        // Update the status of login
        isCurrentlyLoggedOut = FirebaseManager.shared.auth.currentUser?.uid == nil
    }
    
    
    /**
     Inputs: email and password
     This function takes the email and the password of the user to login the authentication of Fireabse. It will return error if the process fails,
     
     */
    func loginUser(email: String, password: String){
        FirebaseManager.shared.auth.signIn(withEmail: email, password: password){
            result, error in
            
            // Catch any error occurs
            if let error = error {
                print("Failed to login user \(error)")
                return
            }
            
            // Print the message of successful login to the console
            self.isCurrentlyLoggedOut = false
            print("Successfully logged in and the id of the user is \(result!.user.uid)")
            
        }
    }
    
    
    /**
     Inputs: email and password of the user as well as the image
     This function takes the email and password of the user to create an account in the firebase database and associates it with the image of the user.
     */
    func createNewAccount(email: String, password: String, image:UIImage, userName: String, gender: String, age: String, phoneNumber: String){
        FirebaseManager.shared.auth.createUser(withEmail: email, password: password) { [self] result, error in
            if let error = error {
                print("Failed to create user for the error \(error)")
                return
            }
            
            print("User \(result!.user.uid) is created.")
            
            
            // Automatically login the account after being created
            self.loginUser(email: email, password: password)
            
            // Save the image of the user in the storage
            saveImageToStorage(email: email, image: image)
            
            // Save other information of the user
            saveUserOtherInformation(userName: userName, gender: gender, email: email, age: age, phoneNumber: phoneNumber)
        }
    }
    
    
    /**
     Inputs: email and image of the user
     This function takes the email and image of the user and saves them to the storage of firebase
     
     */
    func saveImageToStorage(email: String, image: UIImage){
        
        // Check whether the user has logined
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {return}
        
        // Create the reference of the image in storage by the uid of the user
        let ref = FirebaseManager.shared.storage.reference(withPath: uid)
        
        // Compress the image
        guard let imageData = image.jpegData(compressionQuality: 5) else{return}
        
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
                print(url?.absoluteString ?? "error")
                guard let url = url else{return}
                self.saveUserImageInformation(imageProfileURL: url)
            }
        }
    }
    
    /**
     Inputs: name, gender, email, age, phone number of the user
     Save them and the uid into the collection.
     */
    func saveUserOtherInformation(userName: String, gender: String, email: String, age: String, phoneNumber: String){
        // Confirm login status and obtain the uid of the current user
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else{return}
        
        let userData = ["useruid": uid, "username": userName, "gender": gender
                        , "email": email, "age": age, "phonenumber": phoneNumber]
        
        FirebaseManager.shared.firestore
            .collection("users")
            .document(uid)
            .setData(userData)
        
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
            .setData(userData)
    }
    
    
    /**
     The current user will sign out by calling this function.
     */
    func userSignOut(){
        isCurrentlyLoggedOut = true
        try? FirebaseManager.shared.auth.signOut()
    }
    
    
    
}
