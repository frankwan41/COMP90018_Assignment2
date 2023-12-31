//
//  UserModel.swift
//  COMP90018_APP
//
//  Created by Junran Lin on 14/9/2023.
//

import Foundation
import Firebase
import FirebaseFirestore

struct User: Identifiable, Codable, Hashable {
    var id: String {
        uid
    }
    
    let uid: String
    var userName: String
    var gender: String
    var email: String
    var profileImageURL: String
    var age: String
    var phoneNumber: String
    var likedPostsIDs: [String]
    var likedCommentsIDs: [String]
    var isActive: Bool
    var currentLatitude: Double
    var currentLongitude: Double
    var infoVisibility: Bool
    var locationTimestamp: Timestamp

    
    init(data: [String: Any]){
        self.uid = data["uid"] as? String ?? ""
        self.userName = data["username"] as? String ?? ""
        self.gender = data["gender"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.profileImageURL = data["profileimageurl"] as? String ?? ""
        self.age = data["age"] as? String ?? ""
        self.phoneNumber = data["phonenumber"] as? String ?? ""
        self.likedPostsIDs = data["likedpostsids"] as? [String] ?? [""]
        self.likedCommentsIDs = data["likedcommentsids"] as? [String] ?? [""]
        self.isActive = data["isactive"] as? Bool ?? false
        self.currentLatitude = data["currentlatitude"] as? Double ?? 0.0
        self.currentLongitude = data["currentlongitude"] as? Double ?? 0.0
        self.infoVisibility = data["infovisibility"] as? Bool ?? false
        self.locationTimestamp = (data["locationtimestamp"] as? Timestamp ?? Timestamp(date: Date()))
        
        
    }
    
}



