//
//  UserModel.swift
//  COMP90018_APP
//
//  Created by Junran Lin on 14/9/2023.
//

import Foundation
import Firebase

struct User: Decodable, Identifiable{
    var userUID: String
    var userName: String
    var gender: String
    var email: String
    var profileImageURL: String
    
    init(data: [String: Any]){
        self.userUID = data["useruid"] as? String ?? ""
        self.userName = data["username"] as? String ?? ""
        self.gender = data["gender"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.profileImageURL = data["profileimageurl"] as? String ?? ""
    }
    
}


extension User{
    var id: String{
        return userUID
    }
}
