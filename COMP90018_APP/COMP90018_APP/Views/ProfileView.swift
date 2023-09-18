//
//  ProfileView.swift
//  COMP90018_APP
//
//  Created by frank w on 14/9/2023.
//

import SwiftUI

struct ProfileView: View {
    
    
    var body: some View {
        NavigationView{
            VStack(spacing: 20){
                Text("This is the profile view")
                NavigationLink {
                    ProfileSetttingView()
                } label: {
                    Text("Found out user profile page")
                }
                NavigationLink {
                    SignView(userViewModel: UserViewModel())
                } label: {
                    Text("Click here to signin/singup")
                }
                
            }
        }


    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack{
            ProfileView()
        }
    }
}
