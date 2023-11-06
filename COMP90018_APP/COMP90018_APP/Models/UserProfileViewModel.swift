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
    private var userId: String

    init(userId: String) {
        self.userId = userId
        fetchUserPosts()
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
}
