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
    
    
    @State private var showImagePicker = false
    @State private var showImageCamera = false
    @State private var showActionSheet = false
    @State private var profileImageIsChanged = false
    @State private var images: [UIImage] = []
    let maxImagesCount = 9
    
    var body: some View {
        VStack {
            if viewModel.user == nil{
                Text("Loading...")
                    .frame(alignment: .center)
                    .tint(.orange)
            }
            VStack{
                Spacer()
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
                
                
                // TODO: Display the ADD IMAGE button if no text typed
                if viewModel.newMessageText.isEmpty{
                    Button{
                        // TODO: Show Image Picker
                        showActionSheet = true
                        
                    }label:{
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                            .background(.orange)
                            .font(.headline)
                            .bold()
                            .clipShape(Circle())
                            .font(.headline)
                    }
                    
                    
                }else{
                    Button {
                        if !viewModel.newMessageText.isEmpty{
                            viewModel.sendNewMessage()
                        }
                    } label: {
                        Text("Send")
                            .padding(.trailing)
                            .tint(Color.orange)
                            .bold()
                            .font(.headline)
                    }
                }
            }
            .padding()
        }
        .navigationTitle(viewModel.user?.userName ?? "Loading...")
        .navigationBarTitleDisplayMode(.inline)
        
        
        .confirmationDialog("", isPresented: $showActionSheet, actions: {
            Button("Taking Photo") {
                showImageCamera = true
            }
            Button("Select photos from album") {
                showImagePicker = true
            }
        })
        .sheet(isPresented: $showImageCamera) {
            ImagePicker(sourceType: .camera) { selectedImage in
                            if let image = selectedImage {
                                images.append(image)
                                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)  // Save to photo library
                                viewModel.sendImages(images: images)
                                images.removeAll()
                            }
                        }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePickerCoordinatorView(maxImageCount: maxImagesCount - images.count,images: $images)
                .onDisappear{
                    viewModel.sendImages(images: images)
                    images.removeAll()
                }
        }
    }
}

