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
    
    let imageWidth: CGFloat = 200
    let imageHeight: CGFloat = 300
    
//    @State var fromProfileImage: UIImage?
//    @State var toProfileImage: UIImage?
    
    @ObservedObject var viewModel: MessageViewModel
    
    
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
                
                if let fromProfileImage = viewModel.fromProfileImage{
                    Image(uiImage: fromProfileImage)
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
                }else{
                    
                    //Image(systemName: "person.fill.questionmark")
                    ProgressView()
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
                    
                }
//                Image(systemName: "arrowtriangle.left.circle.fill")
//                    //.resizable()
//                    .scaledToFill()
//                    .frame(width: 5, height: 5)
//                    //.cornerRadius(50)
//                    //.clipShape(Circle())
//                    .foregroundColor(.orange)
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 44)
//                            .stroke(Color(.label), lineWidth: 1)
//                    )
//                    .shadow(radius: 5)
                
            } else {
                
                // TODO: If this is an image (Done)
                if let toProfileImage = viewModel.toProfileImages[isFromCurrentUser ? message.toId : message.fromId]{
                    
                    Image(uiImage: toProfileImage)
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
                }else{
                    
                    //Image(systemName: "person.fill.questionmark")
                    ProgressView()
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
                    
                }
                
                
                
                
                
//                Image(systemName: "arrowtriangle.right.circle.fill")
//                    //.resizable()
//                    .scaledToFill()
//                    .frame(width: 5, height: 5)
//                    //.cornerRadius(50)
//                    //.clipShape(Circle())
//                    .foregroundColor(.secondary)
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 44)
//                            .stroke(Color(.label), lineWidth: 1)
//                    )
//                    .shadow(radius: 5)
                
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
