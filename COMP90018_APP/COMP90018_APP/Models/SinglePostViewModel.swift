//
//  SinglePostViewModel.swift
//  COMP90018_APP
//
//  Created by bowenfan-unimelb on 25/10/2023.
//

import Foundation

class SinglePostViewModel: ObservableObject {
    
    @Published var comments = [Comment]()
    
    /**
     This function will fetch all comments from the firebase
     */
    func fetchAllComments(commentIDs: [String]) {
        
        // Remove all existing comments
        self.comments.removeAll()
        
        for commentID in commentIDs {
            let docRef = FirebaseManager.shared.firestore
                .collection("comments")
                .document(commentID)

            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let data = document.data()
                    if let data = data {
                        let comment = Comment(data: data)
                        self.comments.append(comment)
                    }
                }
            }
        }
        
    }
    
}
