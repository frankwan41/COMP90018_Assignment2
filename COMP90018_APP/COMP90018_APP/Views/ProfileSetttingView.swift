
//  ProfileSetttingView.swift
//  COMP90018_APP
//
//  Created by frank w on 14/9/2023.
//

import SwiftUI

struct ProfileSetttingView: View {
    @State private var isEditing = false
    @State private var passwordCover: Bool = true
    
    @StateObject var profileSettingViewModel: ProfileSettingViewModel
    
    // Edited input
    @State private var editedEmail = ""
    @State private var editedPassword = ""
    @State private var editedPhoneNumber = ""
    @State private var editedAge = ""
    @State private var editedGender = ""
    @State private var editedUsername = ""
    
    @State private var originalEmail = "Loading..."
    @State private var originalPassword = "Loading..."
    @State private var originalPhoneNumber = "Loading..."
    @State private var originalAge = "Loading..."
    @State private var originalGender = "Loading..."
    @State private var originalUsername = "Loading..."
    
    

    
    var fieldData: [(String, Binding<String>, Bool, String)] {
        [
            //("Email", $editedEmail, false, originalEmail),
            ("Username", $editedUsername, false, originalUsername),
            //("Password", $editedPassword, true, originalPassword),
            ("Phone Number", $editedPhoneNumber, false, originalPhoneNumber),
            ("Age", $editedAge, false, originalAge),
            ("Gender", $editedGender, false, originalGender)
        ]
    }
    
    
    
    
    var body: some View {
        ZStack{
            isEditing ?             Color.black.opacity(0.1).ignoresSafeArea()
            : Color.white.ignoresSafeArea()
            

            VStack{
                Circle().fill(.white)
                    .shadow(radius: 10)
                    .frame(width: 200, height: 200)
                    .padding(.vertical, 50)
                    .overlay(Text("Avatar")
                    )
                    
                
                List {
                    ForEach(fieldData, id: \.0) { (title, value, isSecure, defaultValue) in
                        EditableTextRow(title: title, value: isEditing ? value : .constant(defaultValue), isSecure: isSecure, isEditable: isEditing, passwordCover: $passwordCover)
                            .padding(.vertical, 10)
                    }
                }
                .listStyle(.inset)
                .navigationBarTitle(isEditing ? "Edit Profile" : "User Profile", displayMode: .inline)
                .onAppear {
                    
                    profileSettingViewModel.getUserInformation { user in
                        updateFields(user: user)
                    }
                    
                    
                }
                if isEditing{
                    profileCancelSaveBtn
                }else{
                    profileEditButton
                }
            }
        }
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)

        }
    }
}

// MARK: COMPONENTS

struct EditableTextRow: View {
    var title: String
    @Binding var value: String
    var isSecure: Bool = false
    var isEditable: Bool
    @Binding var passwordCover: Bool
    
    var body: some View {
        HStack{
            Text(title)
            Spacer()
            if isSecure {
                    Group{
                        if passwordCover {
                            SecureField("", text: $value).disabled(!isEditable).multilineTextAlignment(.trailing)
                            
                        }else{
                            TextField("", text: $value).disabled(!isEditable).multilineTextAlignment(.trailing)
                        }
                    }
                    .padding(.trailing, isEditable ? 10 : 0)
                if isEditable{
                    Button {
                        passwordCover.toggle()
                    } label: {
                        Image(systemName: passwordCover ? "eye.slash" :  "eye").accentColor(.gray)
                    }
                }
            } else {
                TextField("", text: $value).disabled(!isEditable).multilineTextAlignment(.trailing)
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
        } label: {
            Text("Edit Profile")
                .frame(width: 200, height: 20)
                .font(.title2)
                .padding()
                .background(Color.blue)
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
            } label: {
                Text("Cancel")
                    .frame(width: 90, height: 20)
                    .font(.title2)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            Button {
                isEditing = false
                passwordCover = true
                
                //originalEmail = editedEmail
                //originalPassword = editedPassword
                
                // Update the details of the user
                profileSettingViewModel.updateUserInformation(userName: editedUsername, gender: editedGender, age: editedAge, phoneNumber: editedPhoneNumber)
                
                // Fetch the latest version of the details of the user
                profileSettingViewModel.getUserInformation { user in
                    updateFields(user: user)
                }
            } label: {
                Text("Save")
                    .frame(width: 90, height: 20)
                    .font(.title2)
                    .padding()
                    .background(Color.blue)
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
        
        // Set initial values for editing fields when the view appears
        //editedEmail = originalEmail
        editedPhoneNumber = originalPhoneNumber
        editedAge = originalAge
        editedGender = originalGender
        editedUsername = originalUsername
        
    }
}


struct ProfileSetttingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack{
            //ProfileSetttingView(profileSettingViewModel: ProfileSettingViewModel())
        }
    }
}
