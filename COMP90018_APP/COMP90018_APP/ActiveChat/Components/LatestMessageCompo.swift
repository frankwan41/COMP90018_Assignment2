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
        formatter.dateFormat = "h:mm a, M/d/yy"
        return formatter
    }
    
    var body: some View {
        VStack {
            HStack(spacing: 8) {
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
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(latestMessage.username)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(latestMessage.text)
                        .font(.subheadline)
                        .foregroundColor(Auth.auth().currentUser?.uid == latestMessage.fromUid ? .secondary : .primary)
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
