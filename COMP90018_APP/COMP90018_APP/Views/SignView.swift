//
//  SignView.swift
//  COMP90018_APP
//
//  Created by frank w on 14/9/2023.
//

import SwiftUI
import Foundation


struct SignView: View {
    
    @StateObject var userViewModel: UserViewModel
    
    @State private var email = ""
    @State private var password = ""
    @State private var passwordCover: Bool = true
    @State private var isSignUpMode: Bool = false
    @State private var hasSubmitted: Bool = false
    @State private var emailInvalidMessage:String = ""
    @State private var passwordInvalidMessage: String = ""
    
    
    var body: some View {

        ZStack{
//            Color.blue.ignoresSafeArea()
            
            
            VStack{
                Text(isSignUpMode ? "Create Account" : "Sign In")
                    .font(.largeTitle)
                    .bold()
                Spacer().frame(height: 50)
                TextField("Email", text: $email)
                    .bold()
                    .padding()
                    .frame(width: 300, height: 50)
                    .background(Color.black.opacity(0.2))
                    .cornerRadius(10)
                Text(emailInvalidMessage).foregroundColor(.red)
                Spacer().frame(height: 30)
                passwordField
                Text(passwordInvalidMessage).foregroundColor(.red)
                Spacer().frame(height: 25)
                Button{
                    handleSubmit()
                    hasSubmitted = true
                }label: {
                    Text(isSignUpMode ? "Sign Up" : "Sign In")
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 300,height: 50)
                        .background(.blue)
                        .cornerRadius(20)
                        .padding(.bottom)
                }
                VStack(alignment: .center, spacing: 10){
                    HStack{
                        Button {
                            // Reset the password
                            
                        } label: {
                            Text(!isSignUpMode ? "Forgot Password?" : "")
                        }
                        
                    }
                    HStack{
                        Text(isSignUpMode ? "Have an account?" : "Don't have an account yet?")
                        Button{
                            isSignUpMode.toggle()
                        }label: {
                            Text(isSignUpMode ? "Sign In" : "Register")
                        }
                    }
                }
            }
            .onChange(of: email) { newValue in
                emailCheckAftSubmit(newValue: newValue)
            }
            .onChange(of: password) { newValue in
                passwordCheckAftSubmit(newValue: newValue)
            }
        }
    }
    
    // MARK: VIEW FUNCTIONS
    // Handle submit button
    private func handleSubmit() {
        if isSignUpMode{
            validInputCheck(email: email, password: password)
            userViewModel.signUpUser(email: email, password: password)
        }
        else{
            validInputCheck(email: email, password: password)
            userViewModel.signInUser(email: email, password: password)
        }
    }
    
    private func validInputCheck(email: String, password: String) {
        if !isValidEmail(email: email) {
            emailInvalidMessage = "Email is not valid format"
            return
        }
        let passwordCheck = isValidPassword(password: password)
        if !passwordCheck.isValid{
            passwordInvalidMessage = passwordCheck.message
            return
        }
    }
    
    // Check if email meet requirements along with changing of email input after submit
    private func emailCheckAftSubmit(newValue: String){
        if hasSubmitted  {
            if isValidEmail(email: newValue){
                emailInvalidMessage = ""
            }else{
                emailInvalidMessage = "Email is not valid format"
            }
        }
    }
    // Check if password meet requirements along with changing of password input after submit
    private func passwordCheckAftSubmit(newValue: String){
        let passwordCheck = isValidPassword(password: newValue)
        if hasSubmitted {
            if passwordCheck.isValid{
                passwordInvalidMessage = ""
            }else{
                passwordInvalidMessage = passwordCheck.message
            }
        }
    }
}


// MARK: COMPONENTS

extension SignView{
    private var passwordField: some View{
        ZStack(alignment: .trailing){
            Group{
                if passwordCover {
                    SecureField("Password", text: $password)
                    
                }else{
                    TextField("Password", text: $password)
                }
            }
            .bold()
            .padding()
            .frame(width: 300, height: 50)
            .background(Color.black.opacity(0.2))
            .cornerRadius(10)
            Button {
                passwordCover.toggle()
            } label: {
                Image(systemName: passwordCover ? "eye.slash" :  "eye").accentColor(.gray)
            }
        }
    }
}

// MARK: FUNCTIONS

// Function to check if an email is valid
func isValidEmail(email: String) -> Bool {
    let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
    let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
    return emailPredicate.evaluate(with: email)
}

// Function to check if a password meets the criteria (length > 8, contains letters, numbers, and special characters)
func isValidPassword(password: String) -> (isValid: Bool, message: String) {
    let lengthRequirement = 8
    let letterRegex = ".*[A-Za-z]+.*"
    let numberRegex = ".*[0-9]+.*"
    let specialCharRegex = ".*[$@$!%*?&]+.*"
    
    if password.count < lengthRequirement {
            return (false, "Password must be at least \(lengthRequirement) characters long.")
    }
    
    if !NSPredicate(format: "SELF MATCHES %@", letterRegex).evaluate(with: password) {
        return (false, "Password must contain at least one letter.")
    }
    
    if !NSPredicate(format: "SELF MATCHES %@", numberRegex).evaluate(with: password) {
        return (false, "Password must contain at least one number.")
    }
    
    if !NSPredicate(format: "SELF MATCHES %@", specialCharRegex).evaluate(with: password) {
        return (false, "Password must contain at least one special character ($@$!%*?&).")
    }
    return (true, "Password is strong.")
    
}




struct SignView_Previews: PreviewProvider {
    static var previews: some View {
        SignView(userViewModel: UserViewModel())
    }
}
