//
//  UserModel.swift
//  COMP90018_APP
//
//  Created by Junran Lin on 14/9/2023.
//

import Foundation
import Firebase

struct User: Decodable {
    var userName: String
    var gender: String
    var email: String
    var profileImageURL: String
    var age: String
    var phoneNumber: String
    var likedPostsIDs: [String]
    
    init(data: [String: Any]){
        self.userName = data["username"] as? String ?? ""
        self.gender = data["gender"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.profileImageURL = data["profileimageurl"] as? String ?? ""
        self.age = data["age"] as? String ?? ""
        self.phoneNumber = data["phonenumber"] as? String ?? ""
        self.likedPostsIDs = data["likedpostsids"] as? [String] ?? [""]
    }
    
}



