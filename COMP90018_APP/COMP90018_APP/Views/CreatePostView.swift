//
//  CreatePostView.swift
//  COMP90018_APP
//
//  Created by frank w on 11/10/2023.
//

import SwiftUI

struct CreatePostView: View {
    @State private var images = Array(repeating: 1, count: 5)
    
    @State private var locationEnable = false
    
    var body: some View {
        NavigationView{
            ScrollView{
                VStack(alignment: .leading){
                        Text("Title......")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.vertical)

                        Text("Say Something")
                            .font(.title2)
                            .padding(.bottom)
                    AddPhotoView(images: $images)
                        .padding(.bottom)
                    Toggle(isOn: $locationEnable) {
                        Text("Add Location".capitalized)
                            .font(.title3)
                            .fontWeight(.bold)
                    }.padding([.vertical,.trailing])
                    AddPostTagsView()
                        
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading)
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            
                        } label: {
                            Text("post".uppercased())
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                        .padding()
                }
        }
        }
    }
}

struct AddPhotoView: View {
    @Binding var images: [Int]
    var maxImagesCount = 9
        
    var body: some View {
        // Calculate number of rows
        let rows = Int(ceil(Double(images.count) / 3.0)) + 1  // add one for add image button
        VStack(alignment: .leading) {
            ForEach(0..<rows) {rowIndex in
                HStack{
                    ForEach(0..<3) {columnIndex in
                        let index = rowIndex * 3 + columnIndex
                        if index < images.count {
                            Rectangle()
                                .fill(.gray.opacity(0.5))
                                .frame(width: 100, height: 100)
                        } else if index == images.count  && index < maxImagesCount {
                            Rectangle().fill(.red)
                                .frame(width: 100, height: 100)
                        }
                    }
                }
            }
        }
    }
}

struct AddPostTagsView: View {
    var body: some View {
        Text("#tag1")
    }
}

struct CreatePostView_Previews: PreviewProvider {
    static var previews: some View {
        CreatePostView()
    }
}
