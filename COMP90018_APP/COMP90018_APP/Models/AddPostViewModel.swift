//
//  AddPostViewModel.swift
//  COMP90018_APP
//
//  Created by Junran Lin on 17/9/2023.
//

import Foundation
import Firebase

class AddPostViewModel{
    /**
     Inputs: title, image , timestamp created of the post and the latitude and longitude of current user
     The function saves the information of the post into the colletion of firebase
     */
    
    func addPost(postTitle: String, image: UIImage?, date: Date, longitude: Double, latitude: Double){
        
        // Confirm the status of login and obtain the userUID
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        // Obtain the username of the user
        FirebaseManager.shared.firestore
            .collection("users")
            .whereField("useruid", isEqualTo: uid)
            .getDocuments { documentsSnapshot, error in
                
                if let error = error{
                    print("Failed to obtain the user name from Firebase \(error)")
                    return
                }
                
                let userName = User(data: (documentsSnapshot?.documents.first?.data())!).userName
                
                // Create the reference of the new post in collection
                let ref = Firestore.firestore().collection("posts").document()
                
                // Put data into the reference
                ref.setData([
                    "id": ref.documentID as String,
                    "title": postTitle,
                    "timestamp": date,
                    "useruid": uid,
                    "username": userName,
                    "longitude": longitude,
                    "latitude": latitude
                ])
                
                // Check if the image exists else fail to add the post
                guard let image = image else {return}
                
                // save the image of the post to the storage
                self.savePostImage(image: image, documentID: ref.documentID as String)
                
            }
        
        
        
    }
    
    /**
     Inputs: image and documentID of the post
     The function saves the image to the storage with reference to its post id and stores the url to image to the information of the post in collections
     
     */
    func savePostImage(image: UIImage, documentID: String){
        // create the reference in the storage by the doumentID of the post
        let ref = FirebaseManager.shared.storage.reference(withPath: documentID)
        
        // Compress the image
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {return}
        
        // Put the compressed image into the storage
        ref.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Error in storing the image \(error.localizedDescription)")
                return
            }
            
            // Obtain the url of the image in the storage
            ref.downloadURL { url, error in
                if let error = error{
                    print("Error in obtaining the url of the image \(error.localizedDescription)")
                    return
                }
                
                // Put the url to the collections of the post
                if let url = url{
                    print("The URL of the image is \(url)")
                    Firestore.firestore()
                        .collection("posts")
                        .document(documentID)
                        .setData(["imageurl": url.absoluteString], merge: true)
                }
            }
        }
        
        
        
        
        
        
        
        
    }
}
