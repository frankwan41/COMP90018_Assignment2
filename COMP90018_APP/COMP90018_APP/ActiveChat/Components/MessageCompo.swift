//
//  MessageCompo.swift
//  COMP90018_APP
//
//  Created by Junran Lin on 28/10/2023.
//

import SwiftUI
import Kingfisher

struct MessageCompo: View {
    let message: Message
    let isFromCurrentUser: Bool
    
    let imageWidth: CGFloat = 300
    let imageHeight: CGFloat = 400
    
    var body: some View {
        HStack {
            if isFromCurrentUser {
                Spacer()
                // TODO: If this is an image (Done)
                if message.isImage{
                    if message.imageUrl.isEmpty{
                        ProgressView()
                            .scaledToFill()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: imageWidth, maxHeight: imageHeight)
                    }else{
                        KFImage(URL(string: message.imageUrl))
                            .resizable()
                            .scaledToFill()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: imageWidth, maxHeight: imageHeight)
                    }
                }else{
                    Text(message.text)
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.orange)
                        .cornerRadius(10)
                }
            } else {
                
                // TODO: If this is an image (Done)
                if message.isImage{
                    if message.imageUrl.isEmpty{
                        ProgressView()
                            .scaledToFill()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: imageWidth, maxHeight: imageHeight)
                    }else{
                        KFImage(URL(string: message.imageUrl))
                            .resizable()
                            .scaledToFill()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: imageWidth, maxHeight: imageHeight)
                    }
                    
                }else{
                    Text(message.text)
                        .foregroundColor(.black)
                        .padding(10)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }
                Spacer()
            }
        }
        .padding(.horizontal)
    }
}

//#Preview {
//    MessageCompo()
//}
