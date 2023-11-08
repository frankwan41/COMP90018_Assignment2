//
//  UserProfileViewModel.swift
//  COMP90018_APP
//
//  Created by Shuyu Chen on 6/11/2023.
//


import Foundation
import Firebase

class UserProfileViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var username: String? = nil
    @Published var userProfileImage: String? = nil
    private var userId: String


    var userViewModel: UserViewModel
    var postCollectionModel: PostCollectionModel

    init(userId: String, userViewModel: UserViewModel, postCollectionModel: PostCollectionModel) {
        self.userId = userId
        self.userViewModel = userViewModel
        self.postCollectionModel = postCollectionModel
        fetchUserPosts()
        fetchUserProfile()
    }
    
    func changeUserUID(newUID: String){
        self.userId = newUID
    }
    
    func fetchUserPosts() {
        FirebaseManager.shared.firestore
            .collection("posts")
            .whereField("useruid", isEqualTo: self.userId)
            .getDocuments { documentsSnapshot, error in
                if let error = error {
                    print("Failed to fetch posts for user \(self.userId), \(error.localizedDescription)")
                    return
                }
                var newPosts = [Post]()
                documentsSnapshot?.documents.forEach { snapshot in
                    let data = snapshot.data()
                    let post = Post(data: data)
                    newPosts.append(post)
                }
                newPosts.sort { $0.timestamp > $1.timestamp }
                DispatchQueue.main.async {
                    self.posts = newPosts
                }
            }
    }
    
    func fetchUserProfile() {
            FirebaseManager.shared.firestore
                .collection("users")
                .document(self.userId)
                .getDocument { documentSnapshot, error in
                    if let error = error {
                        print("Failed to fetch user profile for user \(self.userId), \(error.localizedDescription)")
                        return
                    }
                    guard let data = documentSnapshot?.data() else { return }
                    DispatchQueue.main.async {
                        self.username = data["username"] as? String
                        self.userProfileImage = data["profileImageURL"] as? String
                    }
                }
        }
    }
