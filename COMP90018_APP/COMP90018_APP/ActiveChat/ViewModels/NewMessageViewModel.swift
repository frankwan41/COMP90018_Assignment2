//
//  NewMessageViewModel.swift
//  COMP90018_APP
//
//  Created by Junran Lin on 28/10/2023.
//


import Foundation
import Firebase
import FirebaseFirestore
import CoreLocation

class NewMessageViewModel: ObservableObject {
    @Published var users = [User]()
    @Published var currentUser: User? = nil
    
    init() {
        Task {
            await fetchAllUsers()
        }
    }
    
    @MainActor
    func fetchAllUsers() async {
        do {
            let snapshot = try await Firestore.firestore().collection("users").getDocuments()
            
//            let users = snapshot.documents.compactMap({ try? $0.data(as: User.self) })
            var users = [User]()
            
            snapshot.documents.forEach { snapshot in
                let data = snapshot.data()
                let user = User(data:data)
                users.append(user)
            }
            
            
            
            for user in users{
                if user.uid == Auth.auth().currentUser?.uid{
                    self.currentUser = user
                    
                }
            }
            
            let currentUserCoordinate = CLLocation(latitude: self.currentUser?.currentLatitude ?? 0, longitude: self.currentUser?.currentLongitude ?? 0)
            
            for user in users {
                if user.uid != Auth.auth().currentUser?.uid {
                    
                    
                    // TODO: Only Fetch the users who are active
                    // TODO: Sort the users based on the distance between the user and the selected 
                    if user.isActive{
                        self.users.append(user)
                        self.users.sort{
                            CLLocation(latitude: $0.currentLatitude, longitude: $0.currentLongitude).distance(from: currentUserCoordinate) 
                            <
                            CLLocation(latitude: $1.currentLatitude, longitude: $1.currentLongitude).distance(from: currentUserCoordinate)
                        }
                    }
                    
                }
            }
            
            
            
        } catch {
            print("Failed to get users who are active.")
        }
    }
}
