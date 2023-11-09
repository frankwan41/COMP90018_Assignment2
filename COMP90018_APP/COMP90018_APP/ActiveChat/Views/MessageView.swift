//
//  MessageView.swift
//  COMP90018_APP
//
//  Created by Junran Lin on 28/10/2023.
//

import SwiftUI
import Photos
import Kingfisher

struct MessageView: View {
    
    @ObservedObject var viewModel: MessageViewModel
    @StateObject var userProfileViewModel: UserProfileViewModel
    @State private var isEditing: Bool = false
    
    @State private var showImagePicker = false
    @State private var showImageCamera = false
    @State private var showActionSheet = false
    @State private var profileImageIsChanged = false
    @State private var images: [UIImage] = []
    let maxImagesCount = 9
    
    @Environment(\.dismiss) var dismiss
    
    @State private var showUserProfile = false
    
    init(viewModel: MessageViewModel) {
        self.viewModel = viewModel
        _userProfileViewModel = StateObject(
            wrappedValue: UserProfileViewModel(userId: viewModel.user?.uid ?? "")
        )
    }
    
    var body: some View {
        VStack {
            ZStack{
                HStack{
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "arrowshape.turn.up.left.circle.fill")
                            .tint(.orange)
                            .font(.largeTitle)
                    }
                    .padding(.leading)
                    
                    Spacer()
                }
                
                Text(viewModel.user?.userName ?? "Loading...")
                    .foregroundStyle(Color.orange)
                    .font(.title2)
                    .bold()
                    .padding(.horizontal)
                    .onTapGesture {
                        showUserProfile.toggle()
                    }
                
                HStack{
                    Spacer()
                    
                    Button{
                        showUserProfile.toggle()
                    }label:{
                       Image(systemName: "house")
                            .font(.title2)
                            .tint(.orange)
                    }
                    .padding(.trailing)
                    
                }
            }
            .shadow(radius: 30, x: -10.0, y: -10.0)
            .padding(.top, 2)
            
            
            
            Divider()
            
            ScrollView {
                ScrollViewReader { proxy in
                    VStack {
                        ForEach(viewModel.messages, id:\.id) { message in
                            MessageCompo(message: message, isFromCurrentUser: message.fromId == viewModel.currentUser.uid, viewModel: viewModel)
                                .id(message.id)
                        }
                        
                        
                        HStack {
                            
                        }
                        .id("bottom")
                    }
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
                        Image(systemName: "rectangle.stack.badge.plus.fill")
                            .scaledToFit()
                            .foregroundColor(.orange)
                            .background(.white)
                            .font(.title)
                            .bold()
                            //.clipShape(Circle())
                            .padding(.horizontal)
                    }
                    
                    
                }else{
                    Button {
                        if !viewModel.newMessageText.isEmpty{
                            viewModel.sendNewMessage()
                        }
                    } label: {
                        Text("Send")
                            .padding(.horizontal)
                            .tint(Color.orange)
                            .bold()
                            .font(.headline)
                            
                    }
                }
            }
            .padding()
        }
        
        .fullScreenCover(isPresented: $showUserProfile, content: {
            UserProfileView(userProfileViewModel: userProfileViewModel)
        })

        
        .confirmationDialog("", isPresented: $showActionSheet, actions: {
            Button("Taking Photo") {
                showImageCamera = true
            }
            Button("Select photos from album") {
                PHPhotoLibrary.requestAuthorization { status in
                    if status == .denied || status == .notDetermined {
                        /* User denied permission or left the authorization in an undetermined state
                        Enter code here to handle this event or leave it blank if you don't want to do anything
                        */
                    } else {
                        /*
                        auth_status is either authorized, limited, or restricted. Call wrapper function
                        */
                        self.showImagePicker = true
                    }
                }
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
        .onChange(of: viewModel.user, perform: { user in
            if let user = user {
                userProfileViewModel.changeUserUID(newUID: user.uid)
            }
        })
    }
}

