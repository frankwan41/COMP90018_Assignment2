//
//  RecentMessageCompo.swift
//  COMP90018_APP
//
//  Created by Junran Lin on 28/10/2023.
//

import SwiftUI
import Kingfisher
import Firebase

struct LatestMessageCompo: View {
    
    let latestMessage: LatestMessage
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm, dd/M/yyyy"
        return formatter
    }
    
    var body: some View {
        VStack {
            HStack(spacing: 8) {
                if latestMessage.profileImageUrl.isEmpty{

                    
                    Image(systemName: "person.fill.questionmark")
                        //.resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                        //.cornerRadius(50)
                        //.clipShape(Circle())
                        .foregroundColor(.orange)
                        .overlay(
                            RoundedRectangle(cornerRadius: 44)
                                .stroke(Color(.label), lineWidth: 1)
                        )
                        .shadow(radius: 5)
                    
                    
                }else{
                    KFImage(URL(string: latestMessage.profileImageUrl))
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                        .clipped()
                        .cornerRadius(50)
                        .overlay(
                            RoundedRectangle(cornerRadius: 44)
                                .stroke(Color(.label), lineWidth: 1)
                        )
                        .shadow(radius: 5)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(latestMessage.username)
                        .font(.headline)
                        .foregroundColor(.orange)
                    
                    // TODO: IF this is an image (Done)
                    //Text(latestMessage.text)
                    Text(latestMessage.isImage ? "[Image]" : PrivacyManager.decryptMessage(latestMessage.text, with: latestMessage.fromUid))
                        .font(.subheadline)
                        .foregroundColor(Auth.auth().currentUser?.uid == latestMessage.fromUid ? .secondary : .primary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
                
                Spacer()
                
                Text(dateFormatter.string(from: latestMessage.timestamp.dateValue()))
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            
            Divider()
        }
    }
}

//#Preview {
//    RecentMessageCompo()
//}
