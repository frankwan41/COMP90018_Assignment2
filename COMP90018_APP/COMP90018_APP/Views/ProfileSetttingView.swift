
//  ProfileSetttingView.swift
//  COMP90018_APP
//
//  Created by frank w on 14/9/2023.
//

import SwiftUI
import FirebaseAuth
import FirebaseStorage
import Kingfisher
import Photos

struct ProfileSetttingView: View {
    @State private var isEditing = false
    @State private var passwordCover: Bool = true
    
    @StateObject var profileSettingViewModel: ProfileSettingViewModel
    @ObservedObject var profileViewModel: ProfileViewModel
    
    // Edited input
    @State private var editedEmail = ""
    @State private var editedPassword = ""
    @State private var editedPhoneNumber = ""
    @State private var editedAge = ""
    @State private var editedGender = ""
    @State private var editedUsername = ""
    @State private var editedVisibility = false
    
    @State private var originalEmail = "Loading..."
    @State private var originalPassword = "Loading..."
    @State private var originalPhoneNumber = "Loading..."
    @State private var originalAge = "Loading..."
    @State private var originalGender = "Loading..."
    @State private var originalUsername = "Loading..."
    @State private var originalVisibility = false
    
    @State private var showImagePicker = false
    @State private var showImageCamera = false
    @State private var showActionSheet = false
    @State private var profileImageIsChanged = false
    @State private var images: [UIImage] = []
    @State private var imageChosen: UIImage?
    @State private var profileImage: UIImage?
    
    @StateObject private var keyboard = KeyboardResponder()
    
    var maxImagesCount = 1
    
    @Environment(\.presentationMode) private var presentationMode
    
    var fieldData: [(String, Binding<String>, Bool, String, Bool)] {
        [
            // Comment out or remove the Email and Password if they are not used
            //("Email", $editedEmail, false, originalEmail, false), // Assuming email is not numeric
            ("Username", $editedUsername, false, originalUsername, false), // Assuming username is not numeric
            //("Password", $editedPassword, true, originalPassword, false), // Assuming password is not numeric
            ("Phone Number", $editedPhoneNumber, false, originalPhoneNumber, true),
            ("Age", $editedAge, false, originalAge, true),
            ("Gender", $editedGender, false, originalGender, false) // Assuming gender is not numeric
        ]
    }
    
    var body: some View {
        NavigationView {
            VStack{
                Button {
                    if isEditing{
                        showActionSheet = true
                    }
                } label: {
                    VStack{
                        
                        if let profileImage = profileImage{
                            Image(uiImage: profileImage).resizable()
                                .scaledToFill()
                                .frame(width:200, height: 200)
                                .clipped()
                                .cornerRadius(50)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 44)
                                        .stroke(Color(.label), lineWidth:1)
                                    
                                )
                                .padding(.vertical, 20)
                                .shadow(radius: 10)
                            
                        }else{
                            Image(systemName: "person.circle").resizable()
                                .scaledToFill()
                                .foregroundStyle(Color.orange)
                                .frame(width:200, height: 200)
                                .clipped()
                                .cornerRadius(50)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 44)
                                        .stroke(Color(.label), lineWidth:1)
                                )}
                        
                        
                        if isEditing{
                            Text("Choose the Image")
                                .padding(.vertical, 1)
                                .padding(.horizontal)
                                .foregroundColor(.black)
                                .font(.title2)
                        }
                    }
                }
                
                List {
                    ForEach(fieldData, id: \.0) { (title, value, isSecure, defaultValue, isNumeric) in
                        EditableTextRow(
                            title: title,
                            value: isEditing ? value : .constant(defaultValue),
                            isSecure: isSecure,
                            isEditable: isEditing,
                            isNumeric: isNumeric,
                            passwordCover: $passwordCover
                        )
                        .padding(.vertical, 10)
                    }
                    ToggleableButtonRow(
                        title: "Visibility",
                        isToggled: isEditing ? $editedVisibility : .constant(originalVisibility),
                        isEditable: isEditing
                    ).padding(.vertical, 10)
                }

                .listStyle(.inset)
                .navigationBarTitle(isEditing ? "Edit Profile" : "User Profile", displayMode: .inline)
                .onAppear {
                    
                    profileSettingViewModel.getUserInformation { user in
                        updateFields(user: user)
                    }
                    
                    getProfileImage()
                }
                .onDisappear {
                    profileViewModel.getUserInformation()
                }
                
                if isEditing{
                    if !keyboard.isKeyboardVisible {
                        profileCancelSaveBtn
                    }
                }else{
                    profileEditButton
                }
            }
            .background( isEditing ? Color.black.opacity(0.1).ignoresSafeArea()
                         : Color.orange.opacity(0.1).ignoresSafeArea())
            .toolbar{
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                    }
                }
            }
            .onChange(of: imageChosen, perform: { newValue in
                profileImageIsChanged = true
                profileImage = imageChosen
            })
            
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                
            }
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
                        imageChosen = image
                        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)  // Save to photo library
                    }
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePickerCoordinatorView(maxImageCount: maxImagesCount - images.count,images: $images)
                    .onDisappear {
                        if (images.count != 0){
                            imageChosen = images.first!
                        }
                    }
                    .onAppear {
                        images.removeAll()
                    }
                
            }
        }
        
        
    }
}

// MARK: COMPONENTS

struct EditableTextRow: View {
    var title: String
    @Binding var value: String
    var isSecure: Bool = false
    var isEditable: Bool
    var isNumeric: Bool = false
    @Binding var passwordCover: Bool
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            if isSecure {
                Group {
                    if passwordCover {
                        SecureField("", text: $value)
                            .disabled(!isEditable)
                            .multilineTextAlignment(.trailing)
                    } else {
                        TextField("", text: $value)
                            .disabled(!isEditable)
                            .multilineTextAlignment(.trailing)
                    }
                }
                .padding(.trailing, isEditable ? 10 : 0)
                if isEditable {
                    Button {
                        passwordCover.toggle()
                    } label: {
                        Image(systemName: passwordCover ? "eye.slash" : "eye").accentColor(.gray)
                    }
                }
            } else {
                // Check if the field is supposed to be numeric
                if isNumeric {
                    TextField("", text: Binding<String>(
                        get: { self.value },
                        set: { newValue in
                            // Only allow the value to change if the new value is empty (allow deletion) or a numeric value
                            if newValue.isEmpty || newValue.allSatisfy({ $0.isNumber }) {
                                self.value = newValue
                            }
                        }
                    ))
                    .disabled(!isEditable)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.numberPad) // Display number pad for numeric input
                } else {
                    TextField("", text: $value)
                        .disabled(!isEditable)
                        .multilineTextAlignment(.trailing)
                }
            }
        }
    }
}

struct ToggleableButtonRow: View {
    var title: String
    @Binding var isToggled: Bool
    var isEditable: Bool
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            if isEditable {
                Toggle(isOn: $isToggled) {
                    // Empty view because the label is already provided by the Text(title)
                }
                .labelsHidden() // This will hide the label for the toggle, since the title is already shown
            } else {
                Image(systemName: isToggled ? "checkmark.square" : "square")
                    .onTapGesture {
                        if isEditable {
                            isToggled.toggle()
                        }
                    }
            }
        }
    }
}


extension ProfileSetttingView {
    
    private var profileEditButton: some View{
        Button {
            isEditing = true
            //editedEmail = originalEmail
            //editedPassword = originalPassword
            editedPhoneNumber = originalPhoneNumber
            editedAge = originalAge
            editedGender = originalGender
            editedUsername = originalUsername
            editedVisibility = originalVisibility
        } label: {
            Text("Edit Profile")
                .frame(width: 200, height: 20)
                .font(.title2)
                .padding()
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(10)
            
        }
        .padding(.bottom, 10)
    }
    
    private var profileCancelSaveBtn: some View{
        HStack(spacing: 40){
            Button {
                isEditing = false
                passwordCover = true
                
                profileImageIsChanged = false
                images.removeAll()
                // Fetch the latest version of the details of the user
                getProfileImage()
                profileSettingViewModel.getUserInformation { user in
                    updateFields(user: user)
                }
            } label: {
                Text("Cancel")
                    .frame(width: 90, height: 20)
                    .font(.title2)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            Button {
                isEditing = false
                passwordCover = true
                
                //originalEmail = editedEmail
                //originalPassword = editedPassword
                
                // Update the details of the user
                profileSettingViewModel.updateUserInformation(userName: editedUsername, gender: editedGender, age: editedAge, phoneNumber: editedPhoneNumber, visibility: editedVisibility)
                
                if let profileImage = profileImage{
                    if profileImageIsChanged{
                        profileSettingViewModel.saveProfileImageToStorage(image: profileImage)
                        profileImageIsChanged = false
                        images.removeAll()
                    }
                }
                
                // Fetch the latest version of the details of the user
                profileSettingViewModel.getUserInformation { user in
                    updateFields(user: user)
                }
                
                
            } label: {
                Text("Save")
                    .frame(width: 90, height: 20)
                    .font(.title2)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
        }
    }
    
}



// MARK: Functions

extension ProfileSetttingView{
    
    private func updateFields(user: User?){
        // Obtain the original fields of the user
        //originalEmail = user?.email ?? "Network Error"
        originalPhoneNumber = user?.phoneNumber ?? "Network Error"
        originalAge = user?.age ?? "Network Error"
        originalGender = user?.gender ?? "Network Error"
        originalUsername = user?.userName ?? "Network Error"
        originalVisibility = user?.infoVisibility ?? false
        
        // Set initial values for editing fields when the view appears
        //editedEmail = originalEmail
        editedPhoneNumber = originalPhoneNumber
        editedAge = originalAge
        editedGender = originalGender
        editedUsername = originalUsername
        editedVisibility = originalVisibility
        
    }
    
    
    private func getProfileImage(){
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            print("Unable to get the uid of the user to obtain the profile image.")
            return}
        
        let folderName = "ProfileImages/"
        
        let storageRef = Storage.storage().reference(withPath: folderName+uid)
        storageRef.getData(maxSize: 20 * 1024 * 1024) { data, error in
            if let error = error{
                print("Error while downloading profile image, \(error.localizedDescription)")
                return
            }
            
            guard let imageData = data, let image = UIImage(data: imageData) else {return}
            
            DispatchQueue.main.async {
                profileImage = image
            }
        }
    }
}


struct ProfileSetttingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack{
            //ProfileSetttingView(profileSettingViewModel: ProfileSettingViewModel())
        }
    }
}
