//
//  SinglePostView.swift
//  COMP90018_APP
//
//  Created by frank w on 14/9/2023.
//

import SwiftUI

struct SinglePostView: View {
    
    @State private var likeStates: [Bool] = Array(repeating: false, count: 5)
    @State private var heartScale: CGFloat = 1.0
    @State private var numLikeStates: [Int] = Array(repeating: 32, count: 20)

    
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            ScrollView{
                VStack(spacing: 20){
                    Image(systemName: "photo")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .font(.largeTitle)
                    Text("Titles")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Consequat ac felis donec et odio pellentesque diam. Ut lectus arcu bibendum at varius vel pharetra. Varius vel pharetra vel turpis nunc eget lorem dolor sed. Sed odio morbi quis commodo odio. Pharetra convallis posuere morbi leo urna molestie at. Nisl tincidunt eget nullam non nisi est. Nibh praesent tristique magna sit amet. Sed faucibus turpis in eu mi bibendum neque egestas congue. In arcu cursus euismod quis viverra nibh cras. Tincidunt praesent semper feugiat nibh sed. Maecenas accumsan lacus vel facilisis volutpat est velit egestas. Tristique magna sit amet purus.")
                    HStack{
                        Text("TimeStamp")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    Divider()
                    
                    CommentsSection(likeStates: $likeStates, heartScale: $heartScale, numLikeStates: $numLikeStates)
                }
                .padding(.horizontal)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        // Access user profile
                    } label: {
                        HStack{
                            Image(systemName: "person.circle.fill")
                            Text("Username")
                        }
                        .foregroundColor(.black)
                        
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // Follow
                    } label: {
                        Text("Follow")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(Color.pink)
                            .padding(.horizontal, 15)
                            .padding(.vertical, 5)
                            .background(RoundedRectangle(cornerRadius: 20).stroke(Color.pink))
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button{
                        // Share / Other manipulations
                    }label: {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.black)
                    }
                }
            }
        }
        
    }
}


// MARK: COMPONENTS
struct CommentsSection: View {
    @Binding var likeStates: [Bool]
    @Binding var heartScale: CGFloat
    @Binding var numLikeStates: [Int]
    
    var body: some View {
        VStack(alignment:.leading){
            HStack{
                Text("384 Comments")
                    .font(.headline)
                    .fontWeight(.thin)
                Spacer()
            }.padding(.bottom)
            
            ForEach(1..<5) { index in
                SingleComment(index: index, likeStates: $likeStates, heartScale: $heartScale, numLikeStates: $numLikeStates)
                    .padding(.vertical)
                Divider()
            }
            
        }
    }
}

struct SingleComment: View {
    let index: Int
    @Binding var likeStates: [Bool]
    @Binding var heartScale: CGFloat
    @Binding var numLikeStates: [Int]
    
    var body: some View {

        HStack(alignment: .top, spacing: 10){
            // Front section: contains only user profile photo
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 35, height: 35)
            
            // Middle section: contains username, comments, possible image comment
            VStack(alignment:.leading, spacing: 5){
                Text("Username")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("Comment")
                Image(systemName: "photo")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
            // End section: contains like button and number of likes
            VStack{
                LikeButton(index: index, likeStates: $likeStates, heartScale: $heartScale, numLikeStates: $numLikeStates)
                Text("\(numLikeStates[index])")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
            
        }
    }
}



struct SinglePostView_Previews: PreviewProvider {
    static var previews: some View {
        SinglePostView()
    }
}
