//
//  CommentModel.swift
//  COMP90018_APP
//
//  Created by Junran Lin on 15/9/2023.
//

import Foundation
import Firebase

struct Comment: Decodable{
    var content: String
    var commentID: String
    var likes: Int
    var userID: String
    
    init(data: [String: Any]){
       
        self.content = data["content"] as? String ?? ""
        self.commentID = data["commentid"] as?  String ?? ""
        self.likes = data["likes"] as? Int ?? 0
        self.userID = data["userid"] as? String ?? ""
    }
    
    
    
    
}
