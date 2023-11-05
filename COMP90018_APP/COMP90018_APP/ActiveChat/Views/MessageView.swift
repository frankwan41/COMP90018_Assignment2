//
//  MessageView.swift
//  COMP90018_APP
//
//  Created by Junran Lin on 28/10/2023.
//

import SwiftUI

struct MessageView: View {
    @ObservedObject var viewModel: MessageViewModel
    @State private var isEditing: Bool = false
    
    var body: some View {
        VStack {
            if viewModel.user == nil{
                Text("Loading...")
                    .frame(alignment: .center)
                    .tint(.orange)
            }
            
            ScrollView {
                ScrollViewReader { proxy in
                    VStack {
                        ForEach(viewModel.messages, id:\.id) { message in
                            MessageCompo(message: message, isFromCurrentUser: message.fromId == viewModel.currentUser.uid)
                                .id(message.id)
                        }
                        
                        
                        HStack {
                            
                        }
                        .id("bottom")
                    }
//                    .onReceive(viewModel.$count) { _ in
//                        withAnimation(.easeOut(duration: 0.5)) {
//                            proxy.scrollTo("bottom", anchor: .bottom)
//                        }
//                    }
//                    .onAppear{
//                        if viewModel.messages.count != 0 {
//                            withAnimation(.easeOut(duration: 0.5)) {
//                                //proxy.scrollTo("bottom", anchor: .bottom)
//                                //proxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
//                                proxy.scrollTo(viewModel.messages.last?.id)
//                            }
//                        }
//                    }
                    .onChange(of: isEditing, perform: { _ in
                        withAnimation(.easeOut(duration: 0.5)) {
                            // proxy.scrollTo("bottom", anchor: .bottom)
                            proxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                        }
                    })
                    .onChange(of: viewModel.count) { newValue in
                        withAnimation(.easeOut(duration: 0.5)) {
                            // proxy.scrollTo("bottom", anchor: .bottom)
                            proxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                        }
                    }
                }
                
            }
            
            
            HStack {
                TextField("Enter Message", text: $viewModel.newMessageText, onEditingChanged:{ edit in
                    isEditing = edit
                })
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .font(.body)
                    .foregroundColor(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
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
                        .tint(Color.orange)
                }
            }
            .padding()
        }
        .navigationTitle(viewModel.user?.userName ?? "Loading...")
        .navigationBarTitleDisplayMode(.inline)
    }
}

