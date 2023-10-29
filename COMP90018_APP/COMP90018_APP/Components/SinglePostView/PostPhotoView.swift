//
//  PostPhotoView.swift
//  COMP90018_APP
//
//  Created by Bowen Fan on 28/10/2023.
//

import SwiftUI
import Kingfisher

struct PostPhotoView: View {
    
    @Binding var post: Post
    @Binding var selectedPhotoIndex: Int
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedPhotoIndex) {
                if post.imageURLs.count > 0 {
                    ForEach (0 ..< post.imageURLs.count, id: \.self) { index in
                        KFImage(URL(string: post.imageURLs[index]))
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .font(.largeTitle)
                            .frame(maxWidth: 600, maxHeight: 400)
                    }
                }
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .frame(width: UIScreen.main.bounds.width, height: 300)
        
        GeometryReader { geo in
            HStack(spacing: 8) {
                if post.imageURLs.count > 0 {
                    ForEach(0 ..< post.imageURLs.count, id: \.self) { index in
                        Circle()
                            .frame(width: 8, height: 8)
                            .foregroundColor(selectedPhotoIndex == index ? .pink : .gray)
                    }
                }
            }
            .position(x: geo.size.width / 2, y: geo.size.height - 20)  // Adjust y value to position
        }
    }
}
