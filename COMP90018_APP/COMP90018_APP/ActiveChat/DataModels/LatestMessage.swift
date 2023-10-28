//
//  LatestMessage.swift
//  COMP90018_APP
//
//  Created by Junran Lin on 28/10/2023.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import FirebaseFirestore

struct LatestMessage: Identifiable, Codable {
    @DocumentID var id: String?
    let fromUid: String
    let toUid: String
    let username: String
    let profileImageUrl: String
    let text: String
    let timestamp: Timestamp
    
    init(data: [String: Any]){
        
        self.id = data["id"] as? String ?? ""
        self.fromUid = data["fromUid"] as? String ?? ""
        self.toUid = data["toUid"] as? String ?? ""
        self.username = data["username"] as? String ?? ""
        self.profileImageUrl = data["profileImageUrl"] as? String ?? ""
        self.text = data["text"] as? String ?? ""
        self.timestamp = (data["timestamp"] as? Timestamp ?? Timestamp(date: Date()))
        
    }
}
