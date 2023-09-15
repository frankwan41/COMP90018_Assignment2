//
//  FirebaseManager.swift
//  COMP90018_APP
//
//  Created by Junran Lin on 14/9/2023.
//

import Foundation
import Firebase
import FirebaseStorage

class FirebaseManager: NSObject{
    let auth: Auth
    let storage: Storage
    let firestore: Firestore
    
    static let shared = FirebaseManager()
    
    override init(){
        // Configure with the plist file
        FirebaseApp.configure()
        
        auth = Auth.auth()
        storage = Storage.storage()
        firestore = Firestore.firestore()
        
        super.init()
    }
}
