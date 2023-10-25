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

struct AddPostView: View {
    
    @StateObject var locationManager = LocationManager()
   
    var addPostViewModel = AddPostViewModel()

    @State private var titleText = ""
    @State private var contentText = ""
    @State private var location = "Add Location"
    @State private var longitude = Double(0)
    @State private var latitude = Double(0)
    @State private var images: [UIImage] = []
    @State private var tags: [String] = []
    @State private var showImagePicker = false
    @State private var showImageCamera = false
    @State private var showActionSheet = false
    
    @State private var showLocationAlert = false
    @State private var showLocationSearchSheet = false
    @State private var showLocationRequestAlert = false
    
    var maxImagesCount = 9
    
    @State private var locationEnable = false
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView{
            ScrollView{
                VStack(alignment: .leading){
                    TextField("Title......", text: $titleText)
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.vertical)
                    TextField("Say Something......", text: $contentText)
                        .font(.title2)
                        .padding(.bottom)
                    AddPhotoView(images: $images, showActionSheet: $showActionSheet, maxImagesCount: maxImagesCount)
                        .padding(.bottom)
                    Divider()
                    LocationSection
                    Divider()
                    .padding(.bottom)
                    
                    PostTagsView(tags: $tags)
                        .padding(.bottom)
                    AddPostTagsView(tags: $tags)
                    
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading)
                .padding()
            }
            .alert(isPresented: $showLocationAlert, content: {
                Alert(
                    title: Text("You have to enable location service in the device settings"),
                    dismissButton: .cancel({
                        locationEnable = false
                    })
                    
                )
            })
            .alert(isPresented: $showLocationRequestAlert, content: {
                Alert(
                title: Text("Location Permission Denied"),
                message: Text("The App requires location permission"),
                primaryButton: .default(Text("Go Settings"), action: openAppSettings),
                secondaryButton: .cancel(Text("Reject"))
            )
            })
            .sheet(isPresented: $showLocationSearchSheet, content: {
                LocationSearchView(locationManager: locationManager, locationText: $location, selectedLatitude: $latitude, selectedLongitude: $longitude)
                    
            })
            .confirmationDialog("", isPresented: $showActionSheet, actions: {
                Button("Taking Photo") {
                    showImageCamera = true
                }
                Button("Select photos from album") {
                    showImagePicker = true
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
                        
                        //TODO: Submit the post
                        addPostViewModel.addPost(
                            postTitle:titleText, images: images, date: Date(), longitude: longitude, latitude: latitude, content: contentText, tags: tags, location: location
                        )
                        dismiss()
                        
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
                                Button(action: {
                                            images.remove(at: index)
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
    
    @State private var addPostViewModel = AddPostViewModel()
    @Binding var tags: [String]
    @State private var tagsExsiting: [String] = []
    @State private var searchText: String = ""
    @State private var showDropdown: Bool = false
    var matchingTags: [String] { tagsExsiting.filter { $0.lowercased().contains(searchText.lowercased()) && !searchText.isEmpty }}
    
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
                                if !tags.contains(searchText) {
                                    tags.append(matchingTags[index])
                                    searchText = ""
                                }
                                
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
        .task {
            addPostViewModel.fetchAllTags(){ tagsFetched in
                if let tagsFetched = tagsFetched{
                    tagsExsiting = tagsFetched
                }
            }
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
struct Place: Identifiable{
    let id = UUID().uuidString
    private var mapItem: MKMapItem
    
    init(mapItem: MKMapItem) {
        self.mapItem = mapItem
    }
    
    var name: String {
        self.mapItem.name ?? ""
    }
    
    var address: String {
        let placemark = self.mapItem.placemark
        var cityAndState = ""
        var address = ""
        
        cityAndState = placemark.locality ?? "" // city
        if let state = placemark.administrativeArea {
            // Show either state or city, state
            cityAndState = cityAndState.isEmpty ? state : "\(cityAndState), \(state)"
        }
        
        address = placemark.subThoroughfare ?? "" // address number
        if let street = placemark.thoroughfare {
            // Show the street unless there is a street number, then add street
            address = address.isEmpty ? street : "\(address) \(street)"
        }
        
        if address.trimmingCharacters(in: .whitespaces).isEmpty && !cityAndState.isEmpty {
            // No address
            address = cityAndState
        } else {
            // No city and state
            address = cityAndState.isEmpty ? address : "\(address), \(cityAndState)"
        }
        
        return address
    }
    
    var latitude: CLLocationDegrees {
        self.mapItem.placemark.coordinate.latitude
    }
    
    var longitude: CLLocationDegrees {
        self.mapItem.placemark.coordinate.longitude
    }
    
}

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
