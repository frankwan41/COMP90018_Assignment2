//
//  MessageCompo.swift
//  COMP90018_APP
//
//  Created by Junran Lin on 28/10/2023.
//

import SwiftUI

struct MessageCompo: View {
    let message: Message
    let isFromCurrentUser: Bool
    
    var body: some View {
        HStack {
            if isFromCurrentUser {
                Spacer()
                Text(message.text)
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color.orange)
                    .cornerRadius(10)
            } else {
                Text(message.text)
                    .foregroundColor(.black)
                    .padding(10)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                Spacer()
            }
        }
        .padding(.horizontal)
    }
}

//#Preview {
//    MessageCompo()
//}
