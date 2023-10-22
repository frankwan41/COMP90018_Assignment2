//
//  ProfileSettingViewModel.swift
//  COMP90018_APP
//
//  Created by Junran Lin on 22/10/2023.
//

import Foundation
import Firebase

class ProfileSettingViewModel: ObservableObject{
    @Published var user = User(data: [:])
    
    init(){
        
        // Obtain the information of the user
        getUserInformation();
    }
    
    
    func getUserInformation(){
        
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
                    return
                }
                
                let data = documentSnapshot?.data()
                let user = User(data: data!)
                self.user = user
                print("Successfully fetched the details of the user \(uid)")
                
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
        
        getUserInformation()
    
        
        
    }
    
}
