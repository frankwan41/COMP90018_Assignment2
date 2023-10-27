//
//  LikeBottuonCompoModel.swift
//  COMP90018_APP
//
//  Created by Junran Lin on 27/10/2023.
//

import Foundation
import Firebase


class LikeButtuonCompoModel: ObservableObject{
    
    func getPost(postID: String, completion: @escaping (Post?)-> Void){
        FirebaseManager.shared.firestore
            .collection("posts")
            .document(postID)
            .getDocument{ documentSnapshot, error in
                if let error = error{
                    print("Unable to fetch the post \(postID), \(error.localizedDescription)")
                    completion(nil)
                }
                else if let documentSnapshot = documentSnapshot, let data = documentSnapshot.data(){
                    let post = Post(data: data)
                    print("Successfully fetched the post \(postID)")
                    completion(post)
                }else{
                    completion(nil)
                }
            }
    }
}
