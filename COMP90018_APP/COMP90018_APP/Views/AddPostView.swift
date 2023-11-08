//
//  CreatePostView.swift
//  COMP90018_APP
//
//  Created by frank w on 11/10/2023.
//

import SwiftUI
import Flow
import BSImagePicker
import CoreLocationUI
import MapKit
import Combine
import Foundation
import Photos
import UIKit

struct AddPostView: View {
    
    @StateObject var locationManager = LocationManager()
    @StateObject var keyboard = KeyboardResponder()
   
    var addPostViewModel = AddPostViewModel()

    @State private var titleText = ""
    @State private var contentText = ""
    @State private var location = "Add Location"
    @State private var longitude = Double(0)
    @State private var latitude = Double(0)
    @State private var images: [UIImage] = []
    @State private var tags: [String] = []
    @State private var existingTag: String? = nil

    
    @State private var showInvalidPostAlert: Bool = false
    
    @State private var showImagePicker = false
    @State private var showImageCamera = false
    @State private var showActionSheet = false
    
    @State private var showLocationSearchSheet = false
    @State private var showLocationRequestAlert = false
    
    var maxImagesCount = 9
    
    
    @State private var locationEnable = false
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) var dismiss
    
    let gradientBackground = LinearGradient(
        gradient: Gradient(colors: [Color.orange.opacity(0.2), Color.white.opacity(0.1)]),
        startPoint: .top,
        endPoint: .bottom
    )
    
    var body: some View {
        NavigationView{
            ZStack{
                gradientBackground.edgesIgnoringSafeArea(.all)
                ScrollView{
                    VStack(alignment: .leading){
                        TextEditorView(text: $titleText, placeHolder: "Title", height: 50)
                            .font(.title)
                            .fontWeight(.bold)
                        TextEditorView(text: $contentText, placeHolder: "Say something ...", height: 100)
                            .font(.body)
                        AddPhotoView(images: $images, showActionSheet: $showActionSheet, maxImagesCount: maxImagesCount)
                            .padding(.bottom)
                        Divider()
                        LocationSection
                        Divider()
                            .padding(.bottom)
                        
                        PostTagsView(tags: $tags, existingTag: $existingTag)
                            .padding(.bottom)
                        AddPostTagsView(tags: $tags, existingTag: $existingTag)
                        
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                }
                
                // Tap anywhere on the ZStack to dismiss the keyboard if it's visible
                if keyboard.isKeyboardVisible {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                        .zIndex(1)
                        .ignoresSafeArea()

                }
            }
            .withFooter()
            .alert(isPresented: $showLocationRequestAlert, content: {
                Alert(
                title: Text("Location Permission Denied"),
                message: Text("The App requires location permission"),
                primaryButton: .default(Text("Go Settings"), action: openAppSettings),
                secondaryButton: .cancel(Text("Reject"))
            )
            })
            .alert(isPresented: $showInvalidPostAlert, content: {
                Alert(title: Text("Invalid Post"), message: Text("The post at least need title or an image!"), dismissButton: .destructive(Text("OK")))
            })
            .sheet(isPresented: $showLocationSearchSheet, content: {
                LocationSearchView(locationManager: locationManager, locationText: $location, selectedLatitude: $latitude, selectedLongitude: $longitude)
                    
            })
            .confirmationDialog("", isPresented: $showActionSheet, actions: {
                Button("Taking Photo") {
                    showImageCamera = true
                }
                Button("Select photos from album") {
                    PHPhotoLibrary.requestAuthorization { status in
                        if status == .denied || status == .notDetermined {
                            /* User denied permission or left the authorization in an undetermined state
                            Enter code here to handle this event or leave it blank if you don't want to do anything
                            */
                        } else {
                            /*
                            auth_status is either authorized, limited, or restricted. Call wrapper function
                            */
                            self.showImagePicker = true
                        }
                    }
                }
            })
            .sheet(isPresented: $showImageCamera) {
                ImagePicker(sourceType: .camera) { selectedImage in
                                if let image = selectedImage {
                                    images.append(image)
                                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)  // Save to photo library
                                }
                            }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePickerCoordinatorView(maxImageCount: maxImagesCount - images.count,images: $images)
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
                        
                        if titleText.isEmpty && images.count == 0 {
                            showInvalidPostAlert = true
                            return
                        }
                        
                        addPostViewModel.addPost(
                            postTitle:titleText, images: images, date: Date(), longitude: longitude, latitude: latitude, content: contentText, tags: tags, location: location
                        )
                        dismiss()
                        
                    } label: {
                        Text("Post")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                }
            }
        }
    }
}


// MARK: COMPONENTS

extension AddPostView {
    private var LocationSection: some View {
        Button {
            locationManager.requestPermission { authorized in
                if authorized {
                    showLocationSearchSheet = true
                } else {
                    showLocationRequestAlert = true
                }
                
            }
            
        } label: {
            HStack{
                Image("locationIcon")
                    .resizable()
                    .frame(width: 18,height: 20)
                Text(location.capitalized)
                    .font(.subheadline)
                    .foregroundStyle(.black)
                Spacer()
                
                Image(systemName: "chevron.right")
                    .tint(.gray)
            }
        }

    }
    
}

// Text editor allows text display on the screen width
struct TextEditorView: View {
    @Binding var text: String
    var placeHolder: String
    var height: CGFloat
    
    var body: some View {
        ZStack(alignment: .topLeading){
            TextEditor(text: $text)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: height)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.bottom)
            
            if text.isEmpty {
               Text(placeHolder)
                    .foregroundColor(.gray.opacity(0.6))
                    .padding(.top, 7)
                    .padding(.leading, 7)
                    .allowsHitTesting(false)
           }
        }
    }
}


struct AddPhotoView: View {
    @Binding var images: [UIImage]
    @Binding var showActionSheet: Bool
    var maxImagesCount: Int
    var maxCol: Int = 3
    
    @State private var showImagePicker = false
    @State var img: UIImage? = nil
    
    var body: some View {
        // Calculate number of rows
        let rows = Int(ceil(Double(images.count) / Double(maxCol))) + 1  // add one for add image button
        VStack(alignment: .leading) {
            ForEach(0..<rows, id: \.self) {rowIndex in
                HStack{
                    ForEach(0..<maxCol, id: \.self) {columnIndex in
                        let index = rowIndex * maxCol + columnIndex
                        if index < images.count {
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: images[index])
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipped()
                                // Image delete button
                                Button(action: {                                            images.remove(at: index)
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .font(.caption)
                                                .foregroundColor(.white)
                                                .background(.gray)
                                                .clipShape(Circle())
                                    
                                        }
                            }
                        // Show the add image button if images count is less than 9
                        } else if index == images.count  && index < maxImagesCount {
                            Rectangle().fill(.gray.opacity(0.2))
                                .frame(width: 100, height: 100)
                                .overlay(Image(systemName: "plus")
                                    .resizable()
                                    .foregroundColor(.gray)
                                    .frame(width: 50, height: 50))
                                .onTapGesture {
                                    showActionSheet = true
                                }
                        }
                    }
                }
            }
        }
    }
}

struct PostTagsView: View {
    @Binding var tags: [String]
    @Binding var existingTag: String?
    
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
                        .background(Capsule().fill(Color.orange.opacity(0.2)))
                    
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
                .scaleEffect(existingTag == tags[index] ? 1.2 : 1.0)
                .animation(.linear(duration: 0.3), value: existingTag)
            }
        }
    }
}

struct AddPostTagsView: View {
    
    @State private var addPostViewModel = AddPostViewModel()
    @Binding var tags: [String]
    @Binding var existingTag: String?
    @State private var tagsExisting: [String] = []
    @State private var searchText: String = ""
    @State private var showDropdown: Bool = false

    var matchingTags: [String] {
        guard !searchText.isEmpty else { return [] }
        let lowercasedQuery = searchText.lowercased()
        return tagsExisting.filter { tag in
            return tag.lowercased().contains(lowercasedQuery) ||
                   tag.lowercased().range(of: lowercasedQuery, options: .regularExpression) != nil
        }
    }
    
    
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                TextField("Search or add a tag...", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.trailing)
                Button(action: {
                    let processedString = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                    if !processedString.isEmpty && !tags.contains(processedString) {
                        tags.append(processedString)
                        searchText = ""
                    }
                }) {
                    Text("Add")
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                }
            }
            if !matchingTags.isEmpty {
                ScrollView {
                    VStack(alignment: .leading) {
                        ForEach(matchingTags, id: \.self) { tag in
                            Button(action: {
                                let processedTag = tag.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                                if !tags.contains(processedTag) {
                                    tags.append(processedTag)
                                    searchText = ""
                                }
                            }) {
                                Text(tag)
                                    .padding(10)
                                    .padding(.leading, 5)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.black)
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
                .frame(height: 200)
            }
        }
        .onAppear {
            tagsExisting = [
                // Melbourne tags
                "Melbourne food", "Melbourne coffee", "Melbourne nightlife",
                "Melbourne markets", "Melbourne culture", "Melbourne events",

                // Sydney tags
                "Sydney beaches", "Sydney dining", "Sydney opera house",
                "Sydney markets", "Sydney festivals", "Sydney seafood",

                // Brisbane tags
                "Brisbane river", "Brisbane BBQ", "Brisbane markets",
                "Brisbane street food", "Brisbane local produce",

                // Perth tags
                "Perth beaches", "Perth vineyards", "Perth local cuisine",
                "Perth seafood", "Perth festivals", "Perth street art",

                // Adelaide tags
                "Adelaide wineries", "Adelaide local food", "Adelaide art",
                "Adelaide festivals", "Adelaide beaches", "Adelaide markets",

                // Other tags
                "Australian BBQ", "Australian wildlife", "Australian hiking",
                "Australian surfing", "Australian outback", "Australian road trip"
            ]
        }

    }
}

struct LocationSearchView: View {
    
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    @ObservedObject var locationManager: LocationManager
    
    @StateObject var placeViewModel = LocationViewModel()
    @Binding var locationText: String
    @Binding var selectedLatitude: Double
    @Binding var selectedLongitude: Double
    
    @State private var debounceTimer: AnyCancellable?
    
    var body: some View {
        NavigationView {
            VStack{
                List(placeViewModel.places) {place in
                    VStack(alignment: .leading) {
                        Text(place.name)
                            .font(.title2)
                        Text(place.address)
                            .font(.callout)
                    }
                    .onTapGesture {
                        locationText = "\(place.name)"
                        selectedLatitude = place.latitude
                        selectedLongitude = place.longitude
                        dismiss()
                    }
                }
                .listStyle(.plain)
                .searchable(text: $searchText)
                .onChange(of: searchText, perform: { text in
                    debounceTimer?.cancel()  // 2. Cancel the previous timer
                    
                    // 3. Create a new timer
                    debounceTimer = Just(text)
                        .delay(for: .milliseconds(300), scheduler: DispatchQueue.main)
                        .sink { text in
                            placeViewModel.search(text: text, region: locationManager.region)

                        }
                })
            }
            .onAppear {
                placeViewModel.search(region: locationManager.region)
            }
            .toolbarBackground(.gray.opacity(0.1), for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}


// MARK: UTILITIES

// Open device setting of the application to allow user to grant location permission
func openAppSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: nil)
        }
    }


struct AddPostView_Previews: PreviewProvider {
    static var previews: some View {
        AddPostView()
    }
}
