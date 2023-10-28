//
//  MessageView.swift
//  COMP90018_APP
//
//  Created by Junran Lin on 28/10/2023.
//

import SwiftUI

struct MessageView: View {
    @ObservedObject var viewModel: MessageViewModel
    
    var body: some View {
        VStack {
            if viewModel.user == nil{
                Text("Loading...")
                    .frame(alignment: .center)
                    .tint(.orange)
            }
            
            ScrollView {
                ScrollViewReader { proxy in
                    LazyVStack {
                        ForEach(viewModel.messages) { message in
                            MessageCompo(message: message, isFromCurrentUser: message.fromId == viewModel.currentUser.uid)
                        }
                        
                        HStack {
                            
                        }
                        .id("bottom")
                    }
                    .onReceive(viewModel.$count) { _ in
                        withAnimation(.easeOut(duration: 0.5)) {
                            proxy.scrollTo("bottom", anchor: .bottom)
                        }
                    }
                    .onAppear{
                        withAnimation(.easeOut(duration: 0.5)) {
                            proxy.scrollTo("bottom", anchor: .bottom)
                        }
                    }
                }
                
            }
            
            
            HStack {
                TextField("Enter Message", text: $viewModel.newMessageText)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .font(.body)
                    .foregroundColor(.black)
                    .shadow(radius: 2)
                    .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray, lineWidth: 1)
                    )
                
                Button {
                    if !viewModel.newMessageText.isEmpty{
                        viewModel.sendNewMessage()
                    }
                } label: {
                    Text("Send")
                        .padding(.trailing)
                }
            }
            .padding()
        }
        .navigationTitle(viewModel.user?.userName ?? "")
        .navigationBarTitleDisplayMode(.inline)
    }
}

