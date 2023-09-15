
//  ProfileSetttingView.swift
//  COMP90018_APP
//
//  Created by frank w on 14/9/2023.
//

import SwiftUI

struct ProfileSetttingView: View {
    @State private var isEditing = false
    @State private var passwordCover: Bool = true
    
    // Edited input
    @State private var editedEmail = ""
    @State private var editedPassword = ""
    @State private var editedPhoneNumber = ""
    @State private var editedAge = ""
    @State private var editedGender = ""
    
    @State private var originalEmail = "template@example.com"
    @State private var originalPassword = "password"
    @State private var originalPhoneNumber = "000"
    @State private var originalAge = "100"
    @State private var originalGender = "Male"
    
    
    var fieldData: [(String, Binding<String>, Bool, String)] {
        [
            ("Email", $editedEmail, false, originalEmail),
            ("Password", $editedPassword, true, originalPassword),
            ("Phone Number", $editedPhoneNumber, false, originalPhoneNumber),
            ("Age", $editedAge, false, originalAge),
            ("Gender", $editedGender, false, originalGender),
        ]
    }
    
    
//    init() {
//        // Set initial values for editing fields when the view is initialized
//        _editedEmail = State(initialValue: originalEmail)
//        _editedPassword = State(initialValue: originalPassword)
//        _editedPhoneNumber = State(initialValue: originalPhoneNumber)
//        _editedAge = State(initialValue: originalAge)
//        _editedGender = State(initialValue: originalGender)
//    }
    
    
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
                    // Set initial values for editing fields when the view appears
                    editedEmail = originalEmail
                    editedPassword = originalPassword
                    editedPhoneNumber = originalPhoneNumber
                    editedAge = originalAge
                    editedGender = originalGender
                }
                if isEditing{
                    profileCancelSaveBtn
                }else{
                    profileEditButton
                }
            }
        }
    }
}

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
            editedEmail = originalEmail
            editedPassword = originalPassword
            editedPhoneNumber = originalPhoneNumber
            editedAge = originalAge
            editedGender = originalGender
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
                originalEmail = editedEmail
                originalPassword = editedPassword
                originalPhoneNumber = editedPhoneNumber
                originalAge = editedAge
                originalGender = editedGender
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

struct ProfileSetttingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack{
            ProfileSetttingView()
        }
    }
}
