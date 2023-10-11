//
//  CreatePostView.swift
//  COMP90018_APP
//
//  Created by frank w on 11/10/2023.
//

import SwiftUI
import Flow

struct AddPostView: View {
    @State private var images = Array(repeating: 1, count: 5)
    @State private var tags = Array(repeating: "long tag", count: 5)
    
    @State private var locationEnable = false
    
    @Environment(\.presentationMode) var presentationMode
    
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
                    }
                    .padding([.vertical,.trailing])
                    .padding(.bottom)
                    
                    PostTagsView(tags: $tags)
                        .padding(.bottom)
                    AddPostTagsView(tags: $tags)
                    
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading)
                .padding()
            }
            .keyboardAvoiding()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                    }
                }
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


// MARK: COMPONENTS

struct AddPhotoView: View {
    @Binding var images: [Int]
    var maxImagesCount = 9
    var maxCol: Int = 3
    
    var body: some View {
        // Calculate number of rows
        let rows = Int(ceil(Double(images.count) / Double(maxCol))) + 1  // add one for add image button
        VStack(alignment: .leading) {
            ForEach(0..<rows) {rowIndex in
                HStack{
                    ForEach(0..<maxCol) {columnIndex in
                        let index = rowIndex * maxCol + columnIndex
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

struct PostTagsView: View {
    @Binding var tags: [String]
    
    var body: some View {
        // Flow layout enable different number of columns in each row
        // depending on the length of the tags
        HFlow(spacing: 15) {
            ForEach(tags.indices, id: \.self) {index in
                ZStack(alignment: .topTrailing) {
                    Text(tags[index])
                        .font(.caption)
                        .lineLimit(1)
                        .padding(.vertical, 5)
                        .padding(.horizontal, 10)
                        .background(Capsule().fill(Color.gray.opacity(0.2)))
                    
                    // Top right button for deleting tag
                    Button(action: {
                        tags.remove(at: index)
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .offset(x: 5, y: -5)
                    }
                }
            }
        }
    }
}

struct AddPostTagsView: View {
    
    @Binding var tags: [String]
    @State private var searchText: String = ""
    @State private var showDropdown: Bool = false
    var matchingTags: [String] { tags.filter { $0.lowercased().contains(searchText.lowercased()) && !searchText.isEmpty }}
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                TextField("Search or add a tag...", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.trailing)
                Button(action: {
                    if !searchText.isEmpty && !tags.contains(searchText) {
                        tags.append(searchText)
                        searchText = ""
                    }
                }) {
                    Text("Add")
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                }
            }
            // Display matching tags as dropdown
            if !matchingTags.isEmpty {
                ScrollView {
                    VStack(alignment: .leading) {
                        ForEach(matchingTags.indices, id: \.self) {index in
                            Button(action: {
                                tags.append(matchingTags[index])
                                searchText = ""
                            }) {
                                Text(matchingTags[index])
                                    .padding(10)
                                    .padding(.leading, 5)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            Divider()
                        }
                    }
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                }
                .frame(height: 400)
            }
        }
    }
}

struct AddPostView_Previews: PreviewProvider {
    static var previews: some View {
        AddPostView()
    }
}
