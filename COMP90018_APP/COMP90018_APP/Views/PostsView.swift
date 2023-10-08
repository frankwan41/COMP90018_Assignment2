//
//  PostsView.swift
//  COMP90018_APP
//
//  Created by frank w on 14/9/2023.
//

import SwiftUI

struct PostsView: View {
//    @State var shakeResult: String  = ""
    @State private var searchCategory: String = ""
    
    @State private var likeStates: [Bool] = Array(repeating: false, count: 20)
    @State private var heartScale: CGFloat = 1.0
    @State private var numLikeStates: [Int] = Array(repeating: 32, count: 20)
    
    @AppStorage("viewDisplay") var viewSwitcher = viewPage.welcome
    @AppStorage("shakeResult") var shakeResult = ""
    
    var body: some View {
        NavigationView {
            List{
                Text("This is the posts view!")
                Text("Here is your shake result: \(shakeResult)")
                ForEach(1..<20) { index in
                    ZStack {
                        VStack(alignment:.leading, spacing: 10){
                            Image(systemName: "photo")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .font(.largeTitle)
                            Text("This is the title of the post").font(.headline)
                            HStack(spacing: 4){
                                Image(systemName: "person.circle")
                                Text("User name").font(.subheadline)
                                Spacer()
                                LikeButton(index: index, likeStates: $likeStates, heartScale: $heartScale, numLikeStates: $numLikeStates)
                                Text("\(numLikeStates[index])").font(.subheadline)
                            }
                        }
                        .padding()
                        NavigationLink(destination: SinglePostView().navigationBarBackButtonHidden(true)) {
                            EmptyView()
                        }
                        .opacity(0)  // Making the NavigationLink invisible
                        .allowsHitTesting(false)
                    }
                    
                }
            }
            .toolbar{
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewSwitcher = viewPage.shake
                    } label: {
                        Image(systemName: "dice")
                    }
                    
                    
                }
            }
        }
    }
}

// MARK: COMPONENTS

struct LikeButton: View {
    let index: Int
    @Binding var likeStates: [Bool]
    @Binding var heartScale: CGFloat
    @Binding var numLikeStates: [Int]
    
    var body: some View{
        Button {
            withAnimation {
                // Slightly increase the size for a moment
                heartScale = 1.5
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                withAnimation {
                    heartScale = 1.0 // Return to normal size
                }
            }
            toggleLikes()
            
        } label: {
            Image(systemName: likeStates[index] ? "heart.fill" : "heart")
                .scaleEffect(heartScale)
                .foregroundColor(likeStates[index] ? .red : .gray)
            
        }.buttonStyle(PlainButtonStyle())
    }
    
    // Toggle number of likes, +1 / -1
    func toggleLikes(){
        likeStates[index].toggle()
        if likeStates[index] {
            numLikeStates[index] += 1
        }else{
            numLikeStates[index] -= 1
        }
    }
}


struct PostsView_Previews: PreviewProvider {
    static var previews: some View {
        PostsView()
    }
}
