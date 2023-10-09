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
    
    func addPost(postTitle: String, images: [UIImage], date: Date, longitude: Double, latitude: Double, content: String, tags: [String], comments: [String] = [], likes: Int = 0, location: String){
        
        // Confirm the status of login and obtain the userUID
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        // Obtain the username of the user
        var userName: String = ""
        
        FirebaseManager.shared.firestore
            .collection("users")
            .document(uid)
            .getDocument { documentSnapshot, error in
                if let error = error{
                    print("Failed to fetch the user name of the user \(uid), \(error.localizedDescription)")
                    return
                }
                
                let data = documentSnapshot?.data()
                let user = User(data: data!)
                userName = user.userName
            }
                
                
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
            "latitude": latitude,
            "content": content,
            "tags": tags,
            "comments": comments,
            "likes": likes,
            "location": location
        ])
        
       
        // save the image of the post to the storage
        self.savePostImage(images: images, documentID: ref.documentID as String)
        
                
            
        
    }
    
    /**
     Inputs: image and documentID of the post
     The function saves the image to the storage with reference to its post id and stores the url to image to the information of the post in collections
     
     */
    // TODO: Change to save mulitple images. (Done)
    func savePostImage(images: [UIImage], documentID: String){
        
        var imageURLs = [String]()
        var numberImages = images.count
        
        for idx in 0...(numberImages - 1){
            var imageReference = documentID + String(idx)
            var image = images[idx]
            var imageURL = self.saveSingleImage(image: image, documentID: imageReference)
            imageURLs.append(imageURL)
        }
        
        Firestore.firestore()
            .collection("posts")
            .document(documentID)
            .setData(["imageurls": imageURLs], merge: true)
        
    }
    
    
    func saveSingleImage(image: UIImage, documentID: String) -> String {
        
        var imageURL = ""
        
        // create the reference in the storage by the doumentID of the post
        let ref = FirebaseManager.shared.storage.reference(withPath: documentID)
        
        // Compress the image
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {return ""}
        
        // Put the compressed image into the storage
        ref.putData(imageData, metadata: nil) { metadata, error in
            if let error = error{
                print("Error in storing the image, \(error.localizedDescription)")
                return
            }
            
            //Obtain the url of the image in the storage
            ref.downloadURL { url, error in
                if let error = error{
                    print("Error in obtaining the url of the image \(error.localizedDescription)")
                    return
                }
                
                // Put the url to the collections of the post
                if let url = url{
                    print("The URL of the image is \(url)")
                    imageURL = url.absoluteString
                }
            
            }
        }
        
        return imageURL
        
        
    }
}
