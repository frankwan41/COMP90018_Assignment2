//
//  ProfileViewModel.swift
//  COMP90018_APP
//
//  Created by Junran Lin on 18/9/2023.
//

import Foundation
import Firebase

class ProfileViewModel: PostCollectionModel {

    @Published var user = User(data: [:])
    
    func getUserInformation(){
        
        // Confirm login status and retrieve the uid of the user
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        FirebaseManager.shared.firestore
            .collection("users")
            .document(uid)
            .getDocument { documentSnapshot, error in
                if let error = error{
                    print("Failed to fetch the profile of the user \(uid), \(error.localizedDescription)")
                    return
                }
                
                let data = documentSnapshot?.data()
                let user = User(data: data!)
                self.user = user
                
            }
        
    }
    
}
