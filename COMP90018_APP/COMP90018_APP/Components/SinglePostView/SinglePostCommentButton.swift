//
//  SinglePostCommentButton.swift
//  COMP90018_APP
//
//  Created by Bowen Fan on 28/10/2023.
//

import SwiftUI

struct SinglePostCommentButton: View {
    
    @Binding var post: Post
    @Binding var comments: [Comment]
    @Binding var isTextFieldVisible: Bool
    @Binding var commentText: String
    @FocusState.Binding var autoFocused: Bool
    @StateObject var userViewModel = UserViewModel()
    @State private var showLoginAlert = false
    
    var body: some View {
        Button(action: {
            // Handle message button action
            if (userViewModel.isLoggedIn){
                isTextFieldVisible = true
                autoFocused = true
            }
            else{
                showLoginAlert = true
            }
            
        }) {
            Image(systemName: "ellipsis.message")
                .resizable()
                .frame(width: 27, height: 27)
                .foregroundColor(.black)
                .padding(.vertical)
        }
        .alert(isPresented: $showLoginAlert) {
            Alert(
                title: Text("Login Required"),
                message: Text("You need to log in to comment posts."),
                dismissButton: .default(Text("OK"))
                
            )
        }
    }
}

