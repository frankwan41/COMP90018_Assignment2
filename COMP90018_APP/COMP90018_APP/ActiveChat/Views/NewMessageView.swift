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
            .withFooter()
            .padding(.top)
            .navigationTitle("Active Users")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                            .font(.custom("ChalkboardSE-Bold", size: 20))
                            .tint(.white)
                            .padding(.leading, 10)
                            .padding(.trailing, 3)
                    }
                    .background(.orange)
                    .cornerRadius(10)
                }
            }
            .refreshable {
                Task{
                    await viewModel.fetchAllUsers()
                }
            }
        }
    }
}
