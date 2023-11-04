//
//  SignView.swift
//  COMP90018_APP
//
//  Created by frank w on 14/9/2023.
//

import SwiftUI

struct SignView: View {
    @StateObject var userViewModel: UserViewModel

    @State private var email = ""
    @State private var password = ""
    @State private var username = ""
    @State private var gender = ""
    @State private var phoneNumber = ""
    @State private var age = ""
    
    @State private var passwordCover: Bool = true
    @State private var isSignUpMode: Bool = false
    @State private var hasSubmitted: Bool = false
    @State private var emailInvalidMessage: String = ""
    @State private var passwordInvalidMessage: String = ""

    var body: some View {
        ZStack {
            VStack {
                Text(isSignUpMode ? "Create Account" : "Sign In")
                    .font(.largeTitle)
                    .bold()
                Spacer().frame(height: 20)
                TextField("Email", text: $email)
                    .bold()
                    .padding()
                    .frame(width: 300, height: 50)
                    .background(.primary.opacity(0.2))
                    .cornerRadius(10)
                Text(emailInvalidMessage).foregroundColor(.red)
                Spacer().frame(height: 20)
                passwordField
                VStack {
                    Text(passwordInvalidMessage).foregroundColor(.red)
                    Text(userViewModel.errorMessage).foregroundColor(.red)
                }
                if isSignUpMode { signupExtraField }
                Button(action: handleSubmit) {
                    Text(isSignUpMode ? "Sign Up" : "Sign In")
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 300, height: 50)
                        .background(.orange)
                        .cornerRadius(20)
                        .padding(.bottom)
                }
                toggleSignUpModeView
            }
            .onChange(of: email) { newValue in
                emailCheckAftSubmit(newValue: newValue)
                userViewModel.errorMessage = ""
            }
            .onChange(of: password) { newValue in
                passwordCheckAftSubmit(newValue: newValue)
                userViewModel.errorMessage = ""
            }
        }
    }

    private var passwordField: some View {
        ZStack(alignment: .trailing) {
            Group {
                if passwordCover {
                    SecureField("Password", text: $password)
                } else {
                    TextField("Password", text: $password)
                }
            }
            .bold()
            .padding()
            .frame(width: 300, height: 50)
            .background(.primary.opacity(0.2))
            .cornerRadius(10)
            Button(action: { passwordCover.toggle() }) {
                Image(systemName: passwordCover ? "eye.slash" : "eye")
                    .accentColor(.gray)
            }
        }
    }

    private var signupExtraField: some View {
        ForEach(signupExtras.indices, id: \.self) { index in
            VStack {
                TextField(signupExtras[index].name, text: signupExtras[index].textBinding)
                    .bold()
                    .padding()
                    .frame(width: 300, height: 50)
                    .background(Color.primary.opacity(0.2))
                    .cornerRadius(10)
                if index < signupExtras.count - 1 {
                    Spacer().frame(height: 20)
                }
            }
        }
    }

    private var toggleSignUpModeView: some View {
        VStack(alignment: .center, spacing: 10) {
            if !isSignUpMode {
                Button("Forgot password?") {
                    userViewModel.resetPassword(email: email)
                }
                .foregroundColor(.orange)
            }
            
            HStack {
                Text(isSignUpMode ? "Have an account?" : "Don't have an account yet?")
                Button(action: { isSignUpMode.toggle() }) {
                    Text(isSignUpMode ? "Sign In" : "Register")
                        .fontWeight(.bold)
                        .foregroundStyle(.orange)
                        .underline()
                }
            }
        }
    }

    private func handleSubmit() {
        hasSubmitted = true
        validInputCheck(email: email, password: password)
        if emailInvalidMessage.isEmpty && passwordInvalidMessage.isEmpty {
            if isSignUpMode {
                userViewModel.signUpUser(email: email, password: password, userName: username, gender: gender, age: age, phoneNumber: phoneNumber)
            } else {
                userViewModel.signInUser(email: email, password: password)
            }
        }
    }

    private func validInputCheck(email: String, password: String) {
        emailInvalidMessage = isValidEmail(email: email) ? "" : "Email is not valid format"
        let passwordCheck = isValidPassword(password: password)
        passwordInvalidMessage = passwordCheck.isValid ? "" : passwordCheck.message
    }

    private func emailCheckAftSubmit(newValue: String) {
        if hasSubmitted {
            emailInvalidMessage = isValidEmail(email: newValue) ? "" : "Email is not valid format"
        }
    }

    private func passwordCheckAftSubmit(newValue: String) {
        if hasSubmitted {
            let passwordCheck = isValidPassword(password: newValue)
            passwordInvalidMessage = passwordCheck.isValid ? "" : passwordCheck.message
        }
    }

    var signupExtras: [InputPair] {
        [
            InputPair(name: "Username", textBinding: $username),
            InputPair(name: "Age", textBinding: $age),
            InputPair(name: "Gender", textBinding: $gender),
            InputPair(name: "Phone Number", textBinding: $phoneNumber)
        ]
    }

    func isValidEmail(email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

    func isValidPassword(password: String) -> (isValid: Bool, message: String) {
        let lengthRequirement = 8
        let letterRegex = ".*[A-Za-z]+.*"
        let numberRegex = ".*[0-9]+.*"
        let specialCharRegex = ".*[!&^%$#@()/]+.*"
        
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
            return (false, "Password must contain at least one special character.")
        }
        return (true, "")
    }
}

struct InputPair {
    let name: String
    let textBinding: Binding<String>
}

struct SignView_Previews: PreviewProvider {
    static var previews: some View {
        SignView(userViewModel: UserViewModel())
    }
}
