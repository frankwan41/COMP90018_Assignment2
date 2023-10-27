//
//  AddPostViewModel.swift
//  COMP90018_APP
//
//  Created by Junran Lin on 17/9/2023.
//

import Foundation
import Firebase
import UIKit
import FirebaseFirestore

class AddPostViewModel{
    /**
     Inputs: title, image , timestamp created of the post and the latitude and longitude of current user
     The function saves the information of the post into the colletion of firebase
     */
    
    func addPost(postTitle: String, images: [UIImage], date: Date, longitude: Double, latitude: Double, content: String, tags: [String], location: String, comments: [String] = [], likes: Int = 0 ){
        
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
                
                print("Successfully uploaded the post \(ref.documentID)")
               
                // save the image of the post to the storage
                self.savePostImage(images: images, documentID: ref.documentID as String){ imageURLs in
                    Firestore.firestore()
                        .collection("posts")
                        .document(ref.documentID)
                        .setData(["imageurls": imageURLs], merge: true)
                    print("Successfully saved the images in the post \(ref.documentID)")
                }
                
                // Upload the tags of the post to the collection of the tags
                self.uploadTagsInPost(tags: tags)
            }
                
                
        
                
            
        
    }
    
    /**
     Inputs: image and documentID of the post
     The function saves the image to the storage with reference to its post id and stores the url to image to the information of the post in collections
     
     */
    // TODO: Change to save mulitple images. (Done)
    func savePostImage(images: [UIImage], documentID: String, completion: @escaping ([String]) -> Void){
        
        var imageURLs = [String]()
        let numberImages = images.count
        
        let dispatchGroup = DispatchGroup()
        
        if numberImages != 0 {
            for idx in 0...(numberImages - 1){
                let imageReference = documentID + String(idx)
                let image = images[idx]
                dispatchGroup.enter()
                self.saveSingleImage(image: image, documentID: imageReference){ imageURL in
                    defer{
                        dispatchGroup.leave()
                    }
                    
                    
                    if let imageURL = imageURL{
                        imageURLs.append(imageURL)
                        print("Successfully uploaded the image \(imageURL) of the post \(documentID)")
                        
                    }else{
                        print("Failed to upload one image of the post \(documentID)")
                    }
                }
            }
        }
        

        dispatchGroup.notify(queue: .global()) {
                completion(imageURLs)
            }
        
    }
    
    
    
    func saveSingleImage(image: UIImage, documentID: String, completion: @escaping (String?) -> Void){
        
        
        // create the reference in the storage by the doumentID of the post
        let ref = FirebaseManager.shared.storage.reference(withPath: documentID)
        
        // Compress the image
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Unable to compress the image of post \(documentID)")
            completion(nil)
            return}
        
        // Put the compressed image into the storage
        ref.putData(imageData, metadata: nil) { metadata, error in
            if let error = error{
                print("Error in storing the image, \(error.localizedDescription)")
                print("Failed to upload one of the images in the post \(documentID)")
                completion(nil)
                return
            }
            
            //Obtain the url of the image in the storage
            ref.downloadURL { url, error in
                if let error = error{
                    print("Error in obtaining the url of the image \(error.localizedDescription)")
                    print("Failed to upload one of the images in the post \(documentID)")
                    completion(nil)
                    return
                }
                
                // Put the url to the collections of the post
                if let url = url{
                    print("The URL of the image is \(url)")
                    print("Successfully uploaded one of the images in the post \(documentID)")
                    completion(url.absoluteString)
                }
            
            }
        }
        
        
    }
    
    
    // TODO: Submit the tags to firestore
    func uploadTagsInPost(tags: [String]){
        for tag in tags {
            let tagData = [
                "name": tag
            ] as [String: Any]
            
            FirebaseManager.shared.firestore
                .collection("tags")
                .document(tag)
                .setData(tagData)
            print("Successfully uploaded tag \(tag)")
        }
        
        
    }
    
    // TODO: Fetch all tags from Firestore
    func fetchAllTags(completion: @escaping ([String]?) -> Void) {
        
        
        FirebaseManager.shared.firestore
            .collection("tags")
            .getDocuments { documentsSnapshot, error in
                if let error = error {
                    print("Failed to fecth all tags \(error)")
                    return
                }
                var tags: [String] = []
                
                documentsSnapshot?.documents.forEach({ snapshot in
                    let data = snapshot.data()
                    let tag = Tag(data: data)
                    tags.append(tag.name)
                })
                
                completion(tags)
                
                
            }
        
        completion(nil)
    }
    
}
