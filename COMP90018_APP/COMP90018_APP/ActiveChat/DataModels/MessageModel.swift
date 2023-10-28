//
//  MessageModel.swift
//  COMP90018_APP
//
//  Created by Junran Lin on 28/10/2023.
//

import Foundation


struct Message: Identifiable {
    let id: String
    let fromId: String
    let toId: String
    let text: String
    let date: Date
}
