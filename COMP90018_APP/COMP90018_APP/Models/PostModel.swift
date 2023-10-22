//
//  PostModel.swift
//  COMP90018_APP
//
//  Created by Junran Lin on 14/9/2023.
//

import Foundation
import Firebase


struct Post: Decodable, Identifiable{
    var id: String
    var postTitle: String
    var timestamp: Date
    var userName: String
    var userUID: String
    var imageURLs: [String]
    var longitude: Double
    var latitude: Double
    var content: String
    var tags: [String] // ID format
    var comments: [String] //ID format
    var likes: Int
    var location: String
    
    
    init(data: [String: Any]){
        self.id = data["id"] as? String ?? ""
        self.postTitle = data["title"] as? String ?? ""
        self.timestamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
        self.userName = data["username"] as? String ?? ""
        self.userUID = data["useruid"] as? String ?? ""
        self.imageURLs = data["imageurls"] as? [String] ?? [""]
        self.longitude = data["longitude"] as? Double ?? 0
        self.latitude = data["latitude"] as? Double ?? 0
        self.content = data["content"] as? String ?? ""
        self.tags = data["tags"] as? [String] ?? [""]
        self.comments = data["comments"] as? [String] ?? [""]
        self.likes = data["likes"] as? Int ?? 0
        self.location = data["location"] as? String ?? ""
        
        
    }
}
