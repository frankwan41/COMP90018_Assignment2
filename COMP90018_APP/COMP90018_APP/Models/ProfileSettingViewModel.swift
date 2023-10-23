//
//  ProfileSettingViewModel.swift
//  COMP90018_APP
//
//  Created by Junran Lin on 22/10/2023.
//

import Foundation
import Firebase
import UIKit

class ProfileSettingViewModel: ObservableObject{
    
    
    func getUserInformation(completion: @escaping (User?) -> Void){
        
        // Confirm the login status and retrieve the uid of the user
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            print("Unable to get the uid of the user, check the login state.")
            return
        }
        
        FirebaseManager.shared.firestore
            .collection("users")
            .document(uid)
            .getDocument { documentSnapshot, error in
                if let error = error{
                    print("Failed to fetch the details of the user \(uid), \(error.localizedDescription)")
                    completion(nil)
                }else{
                    if let documentSnapshot = documentSnapshot {
                        let data = documentSnapshot.data()
                        let user = User(data: data!)
                        print("Successfully fetched the details of the user \(uid)")
                        completion(user)
                    }
                }
            }
        
        
    }
    
    
    func updateUserInformation(userName:String, gender:String, age:String, phoneNumber:String){
        
        // Cherck whether the user has logined
        // uid = Auth.auth().currentUser?.uid
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            print("Unable to get the uid of the user, check the login state.")
            return
        }
        
        let updatedData = [
            "username": userName,
            "gender": gender,
            "age": age,
            "phonenumber": phoneNumber
        ] as [String: Any]
        
        FirebaseManager.shared.firestore
            .collection("users")
            .document(uid)
            .updateData(updatedData)
        
        print("Successfully updated the details of user \(uid).")
        
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
    
}


