//
//  HomeViewModel.swift
//  COMP90018_APP
//
//  Created by Junran Lin on 28/10/2023.
//

import Foundation
import Firebase
import FirebaseFirestore

class ChatMainViewModel: ObservableObject {
    
    @Published var latestMessages = [LatestMessage]()
    
    @Published var isFirstFetch = true
    var currentUser: User
    
    @Published var lastTimestamp: Timestamp? = nil
    
    init(currentUser: User) {
        self.currentUser = currentUser
//        fetchRecentMessages()
        lastTimestamp = Timestamp()
    }
    
    private var listenerRegistration: ListenerRegistration?
    
    func fetchRecentMessages() {
        listenerRegistration?.remove()
        self.latestMessages.removeAll()
        
        listenerRegistration = Firestore.firestore().collection("latestMessages")
            .document(currentUser.uid)
            .collection("messages")
            .order(by: "timestamp")
            .addSnapshotListener({ querySnapshot, error in
                if let error = error {
                    print("Failed to listen for recent messages \(error)")
                    return
                }
                self.isFirstFetch = false
                querySnapshot?.documentChanges.forEach({ change in
                    if let rm = try? change.document.data(as: LatestMessage.self) {
                        
                       
                    
                        if let index = self.latestMessages.firstIndex(where: { existingRm in
                            return existingRm.id == rm.id && (existingRm.fromUid == rm.fromUid || existingRm.toUid == rm.fromUid)
                            
                        }) {
                            
                            // Update the latest message if it exists
                            self.latestMessages[index] = rm
                        } else {
                            // Else Append it as the latest one
                            
                            self.latestMessages.insert(rm, at: 0)
                        }
                        
                        // Sort the latest messages based on the timestamp
                        self.latestMessages.sort { $0.timestamp.dateValue() > $1.timestamp.dateValue()
                        }
                        
                        if let newTimestamp = self.latestMessages.first?.timestamp, let oldTimestamp = self.lastTimestamp{
                            if oldTimestamp.dateValue() < newTimestamp.dateValue() {
                                self.lastTimestamp = newTimestamp
                            }
                        }
                    } else {
                        print("Failed to decode document data as recent message.")
                    }
                })
            })
    }
    
    func setUserActiveState(state: Bool, completion: @escaping (String?) -> Void){
        
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else{
            return
        }
        
        let userData = [
            "isactive": state
        ] as [String: Any]
        
        FirebaseManager.shared.firestore
            .collection("users")
            .document(uid)
            .updateData(userData){ error in
                if let error = error {
                    print("Failed to update Active state \(error.localizedDescription)")
                    completion(nil)
                }
                
                completion("Success")
                
            }
        
        completion(nil)
    }
    
    func updateUserCurrentLocation(latitude: Double, longitude: Double, completion: @escaping (String?) -> Void){
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else{
            return
        }
        
        let userData = [
            "currentlatitude": latitude,
            "currentlongitude": longitude,
            "locationtimestamp": Timestamp()
        ] as [String: Any]
        
        FirebaseManager.shared.firestore
            .collection("users")
            .document(uid)
            .updateData(userData){ error in
                if let error = error {
                    print("Failed to update location \(error.localizedDescription)")
                    completion(nil)
                }
                completion("Success")
                
            }
    }
}

