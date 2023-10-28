//
//  NewMessageCompo.swift
//  COMP90018_APP
//
//  Created by Junran Lin on 28/10/2023.
//
import SwiftUI
import Kingfisher

struct NewMessageCompo: View {
    var user: User
    
    var body: some View {
        HStack(spacing: 16) {
            
            if !user.profileImageURL.isEmpty{
                KFImage(URL(string: user.profileImageURL))
                    .resizable()
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
            }else{
                Image(systemName: "person.circle")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
            }
            
            
            
            VStack(alignment: .leading, spacing: 8) {
                Text(user.userName)
                    .font(.headline)
                    .foregroundColor(.black)
                
                Text(user.email)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding(16)
    }
}


//#Preview {
//    NewMessageCompo()
//}
