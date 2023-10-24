//
//  TagModel.swift
//  COMP90018_APP
//
//  Created by Junran Lin on 18/9/2023.
//

import Foundation

struct Tag: Decodable{
    var name: String
    
    init(data: [String: Any]){
        
        self.name = data["name"] as?  String ?? ""

    }
    
    
    
    
}
