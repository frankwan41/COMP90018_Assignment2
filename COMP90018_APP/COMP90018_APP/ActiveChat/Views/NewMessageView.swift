//
//  NewMessageView.swift
//  COMP90018_APP
//
//  Created by Junran Lin on 28/10/2023.
//

import SwiftUI

struct NewMessageView: View {
    let didSelectUser: (User) -> ()
    @Environment(\.dismiss) var dismiss
    
    @StateObject var viewModel = NewMessageViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    LazyVStack {
                        ForEach(viewModel.users) { user in
                            Button {
                                dismiss()
                                didSelectUser(user)
                            } label: {
                                NewMessageCompo(user: user, newMessageViewModel: viewModel)
                            }
                            
                            Divider()
                        }
                    }
                }
            }
            .padding(.top)
            .navigationTitle("New Message")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }
            }
        }
    }
}
