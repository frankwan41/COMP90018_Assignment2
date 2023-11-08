//
//  SinglePostView.swift
//  COMP90018_APP
//
//  Created by frank w on 14/9/2023.
//

import SwiftUI
import Flow
import Kingfisher
import CoreLocation
import MapKit


struct SinglePostView: View {
    
    
    @AppStorage("shakeResult") var shakeResult = ""
    @Environment(\.dismiss) var dismiss
    
    @State private var showAlert: Bool = false
    @State private var showLocationRequestAlert: Bool = false
    @State private var showLocationDistance: Bool = false
    @State private var showDistanceFarAlert: Bool = false
    var closeDistance: Double = 1000
    var farDistance: Double = 50000
    @State private var temperature: Int = 0
    @State private var cityName: String = ""
    @State private var weatherDescription: String = ""
        
    @StateObject var locationManager = LocationManager()
    
    @Binding var post: Post
    @State var comments: [Comment] = []
    @State var currentUser: User? = nil
    
    @State private var isTextFieldVisible = false
    @FocusState private var autoFocused: Bool
    @State private var commentText: String = ""
    
    @State private var selectedPhotoIndex = 0
    
    @StateObject private var userViewModel = UserViewModel()
    @StateObject private var singlePostViewModel = SinglePostViewModel()
    @StateObject var userProfileViewModel: UserProfileViewModel
    
    @EnvironmentObject var speechRecognizer: SpeechRecognizerViewModel
    @State private var microphoneAnimate = false
    
    @State var authorUsername: String?
    @State var profileImageURL: String?
    
    private let dateFormatter = DateFormatter()
    @State var dateTimeText: String = "";
    
    var openMapCommand: String = "map"
    var checkWeatherCommand: String = "weather"
    
    @State var showUserProfile: Bool = false
    
    @Environment(\.presentationMode) var presentationMode
    

    init(post: Binding<Post>) {
            self._post = post
            
            self._userProfileViewModel = StateObject(wrappedValue: UserProfileViewModel(userId: post.wrappedValue.userUID))
        }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Create a background gray effect when text editor for comment is visible
                Color.gray.opacity(isTextFieldVisible ? 0.5 : 0) // Background color
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        if post.imageURLs.count > 0 {
                            PostPhotoView(post: $post, selectedPhotoIndex: $selectedPhotoIndex)
                        }
                        Text(post.postTitle)
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        Text(post.content)
                            .padding(.horizontal)
                        TagsSection
                            .padding(.horizontal)
                        HStack {
                            Text(dateTimeText)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .padding(.leading)
                            //Text(post.location)
                                //.font(.subheadline)
                                //.foregroundColor(.blue)
                            Button(action: {
                                let userLatitude = locationManager.location?.latitude ?? 0
                                let userLontitude = locationManager.location?.longitude ?? 0
                                
                                let postCoordinate = CLLocation(latitude: post.latitude, longitude: post.longitude)
                                let userCoordniate  = CLLocation(latitude: userLatitude, longitude: userLontitude)
                                
                                let distance = userCoordniate.distance(from: postCoordinate).rounded()
                                // If the location is less than 50 km, navigate to map
                                if distance <= farDistance {
                                    // Open Map for navigation
                                    openMapsForNavigation(toLatitude: post.latitude, longitude: post.longitude, locationName: post.location)
                                }else{
                                    showDistanceFarAlert = true
                                }
                            }){
                                Text(post.location)
                            }
                            .font(.subheadline)
                            .foregroundColor(.blue)
                            Spacer()
                        }
                        Divider()
                        
                        CommentsSection(post: $post, comments: $comments)
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
                            showUserProfile.toggle()
                        } label: {
                            HStack {
                                // Get user profile picture
                                if let urlString = profileImageURL, let url = URL(string: urlString) {
                                    KFImage(url)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 30, height: 30)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.black, lineWidth: 1))
                                } else {
                                    // Display a default profile image
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 30, height: 30)
                                        .overlay(Circle().stroke(Color.black, lineWidth: 1))
                                    
                                }
                                if let username = authorUsername {
                                    Text(username)
                                        .truncationMode(.tail)
                                        .frame(width: 100)
                                }
                            }
                            .foregroundColor(.black)
                        }
                    }

                    // Only show the distance tip/distance if the post has location
                    if (post.longitude != 0 && post.latitude != 0) {
                        // If the location is enabled, show distance direclty, otherwise show distance tip button for enable location service
                        if showLocationDistance {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                let userLatitude = locationManager.location?.latitude ?? 0
                                let userLontitude = locationManager.location?.longitude ?? 0
                                
                                let postCoordinate = CLLocation(latitude: post.latitude, longitude: post.longitude)
                                let userCoordniate  = CLLocation(latitude: userLatitude, longitude: userLontitude)
                                
                                let distance = userCoordniate.distance(from: postCoordinate).rounded()
                            
                                    Button(action: {
                                        // If the location is less than 50 km, navigate to map
                                        if distance <= farDistance {
                                            // Open Map for navigation
                                            openMapsForNavigation(toLatitude: post.latitude, longitude: post.longitude, locationName: post.location)
                                        }else{
                                            showDistanceFarAlert = true
                                        }
                                    }) {
                                        if distance < closeDistance {
                                            // If less than 1000 meters, show in meters
                                            Text("\(String(format: "%.0f", distance)) m")
                                                .font(.system(size: 12))
                                                .fontWeight(.bold)
                                                .foregroundColor(Color.white)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 2)
                                                .background(RoundedRectangle(cornerRadius: 20).fill(Color.orange))
                                        } else {
                                            // If 1 km or more, convert to kilometers
                                            let distanceInKilometers = distance / closeDistance
                                            VStack{
                                                Text("\(String(format: "%.0f", distanceInKilometers)) km")
                                                //Text("Go Here").font(.system(size: 8))
                                            }
                                            .font(.system(size: 12))
                                            .fontWeight(.bold)
                                            .foregroundColor(Color.white)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 2)
                                            .background(RoundedRectangle(cornerRadius: 20).fill(Color.orange))
                                        }
                                    }
                                    .alert(isPresented: $showDistanceFarAlert, content: {
                                        Alert(
                                            title: Text("Confirmation"),
                                            message: Text("This distance is over \(String(format: "%.0f", farDistance/closeDistance))km, Are you sure you want to proceed?"),
                                            primaryButton: .default(Text("Yes")) {
                                                // Open Map for navigation
                                                openMapsForNavigation(toLatitude: post.latitude, longitude: post.longitude, locationName: post.location)
                                            },
                                            secondaryButton: .cancel()
                                        )
                                    })
                                
                            }
                        }else{
                            ToolbarItem(placement: .navigationBarTrailing) {
                                
                                
                                Button {
                                    locationManager.requestPermission { authorized in
                                        if authorized {
                                            showLocationDistance = true
                                        } else {
                                            showLocationRequestAlert = true
                                        }
                                        
                                    }
                                } label: {
                                    Text("Distance")
                                        .font(.system(size: 12))
                                        .fontWeight(.bold)
                                        .foregroundColor(Color.white)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(RoundedRectangle(cornerRadius: 20).fill(Color.orange))
                                }
                                .alert(isPresented: $showLocationRequestAlert, content: {
                                    Alert(
                                        title: Text("Location Permission Denied"),
                                        message: Text("The App requires location permission"),
                                        primaryButton: .default(Text("Go Settings"), action: openAppSettings),
                                        secondaryButton: .cancel(Text("Reject"))
                                    )
                                })
                            }
                        }
                    }
                    if (post.longitude != 0 && post.latitude != 0) {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                if let apiKey = Bundle.main.object(forInfoDictionaryKey: "OpenWeatherAPIKey") as? String {
                                    getWeather(latitude: post.latitude, longitude: post.longitude, apiKey: apiKey)
                                }
                            } label: {
                                Text("Weather")
                                    .font(.system(size: 12))
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(RoundedRectangle(cornerRadius: 20).fill(Color.orange))
                            }
                            
                            .alert(isPresented: $showAlert) {
                                Alert(title: Text("Weather Info for \(cityName)"),
                                      message: Text("Temperature: \(temperature)°C \nCondition: \(weatherDescription)"),
                                      dismissButton: .default(Text("Got it!")))
                            }
                        }
                    }
//                    ToolbarItem(placement: .navigationBarTrailing) {
//                        Button{
//                            // Share / Other manipulations
//                        }label: {
//                            Image(systemName: "square.and.arrow.up")
//                                .foregroundColor(.black)
//                        }
//                    }
            }
                
                // Disable the text editor when tap screen
                if (isTextFieldVisible) {
                    Button(action: {
                        autoFocused = false
                        isTextFieldVisible = false
                    }){
                        Color.clear.ignoresSafeArea()
                    }
                }

                if isTextFieldVisible {
                    CommentTextField(
                        post: $post,
                        comments: $comments,
                        commentText: $commentText,
                        isTextFieldVisible: $isTextFieldVisible,
                        autoFocused: $autoFocused
                    )
                } else {
                    BottomBar
                }
                
            }
            .fullScreenCover(isPresented: $showUserProfile, content: {
                UserProfileView(userProfileViewModel: userProfileViewModel)
            })
            
        }
        .onAppear {
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            dateTimeText = dateFormatter.string(from: post.timestamp)
            userViewModel.getCurrentUser { user in
                if let user = user {
                    self.currentUser = user
                }
            }
            userViewModel.getUser(userUID: post.userUID) { user in
                if let user = user {
                    authorUsername = user.userName
                    profileImageURL = user.profileImageURL
                } else {
                    authorUsername = nil
                    profileImageURL = nil
                }
            }
            singlePostViewModel.getPostComments(postID: post.id) { comments in
                if let comments = comments {
                    self.comments = comments
                }
            }
            
            singlePostViewModel.getPost(postID: post.id) { newPost in
                if let newPost = newPost{
                    self.post = newPost
                }
            }
        
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                if locationManager.status == Status.success {
                    showLocationDistance = true
                }
            }
            userProfileViewModel.changeUserUID(newUID: post.userUID)
            
        }
        .onChange(of: speechRecognizer.commandText, perform: { speech in
            if speechRecognizer.commandText.lowercased().contains(openMapCommand) {
                if showLocationDistance{
                    DispatchQueue.main.async {
                        speechRecognizer.resetSpeechTexts()
                        openMapsForNavigation(toLatitude: post.latitude, longitude: post.longitude, locationName: post.location)
                    }
                }else {
                    locationManager.requestPermission { authorized in
                        if authorized {
                            showLocationDistance = true
                        } else {
                            showLocationRequestAlert = true
                        }
                    }
                }
            }
            if speechRecognizer.speechText.lowercased().contains(checkWeatherCommand) {
                DispatchQueue.main.async {
                    speechRecognizer.resetSpeechTexts()
                    let apiKey = "95e381fda50cae025af8d88dde3f5c5c"
                    getWeather(latitude: post.latitude, longitude: post.longitude, apiKey: apiKey)
                }
            }
        })
        .refreshable {
            singlePostViewModel.getPostComments(postID: post.id) { comments in
                if let comments = comments {
                    self.comments = comments
                }
            }
        }
        
    }
    struct WeatherData: Codable {
        let main: Main
        let weather: [Weather]
        let name: String
        
        struct Main: Codable {
            let temp: Double
        }
        
        struct Weather: Codable {
            let description: String
        }
    }
    
    func getWeather(latitude: Double, longitude: Double, apiKey: String){
        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=metric"
        if let url = URL(string: urlString) {
                let task = URLSession.shared.dataTask(with: url) { data, response, error in
                    if let data = data {
                        do {
                            let decoder = JSONDecoder()
                            let weatherData = try decoder.decode(WeatherData.self, from: data)
                            DispatchQueue.main.async {
                                self.temperature = Int(weatherData.main.temp)
                                if let weatherDescription = weatherData.weather.first?.description {
                                    self.weatherDescription = weatherDescription
                                }
                                self.showAlert = true
                                self.cityName = weatherData.name
                                if(self.cityName == "" || self.cityName == "Globe" || self.cityName.isEmpty){
                                    self.cityName = "your destination"
                                }
                            }
                        } catch {
                            print("Error decoding the data: \(error.localizedDescription)")
                        }
                    } else if let error = error {
                        print("Error fetching data: \(error.localizedDescription)")
                    }
                }
                task.resume()
            }
    }
    
}


// MARK: COMPONENTS

extension SinglePostView {
    private var BottomBar: some View {
        VStack {
            
            Spacer()  // Push the HStack to the bottom of the ZStack
            HStack {
                Spacer()
                HStack {
                    LikeButtonPost(
                        width: 30,
                        height: 25,
                        post: $post,
                        userViewModel: userViewModel
                    )
                    Text(String(post.likes))
                }
                // Pushes the two buttons apart
                Spacer(minLength: 0)
                if speechRecognizer.commandListerning {
                    Image(systemName: "mic.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        .scaleEffect(microphoneAnimate ? 1.2 : 1) // Pulsing effect
                        .opacity(microphoneAnimate ? 0.7 : 1) // Changes the opacity
                        .onAppear {
                            withAnimation(Animation.easeInOut(duration: 0.7).repeatForever(autoreverses: true)) {
                                microphoneAnimate = true
                            }
                        }

                }
                Spacer(minLength: 0)
                HStack {
                    SinglePostCommentButton(
                        post: $post,
                        comments: $comments,
                        isTextFieldVisible: $isTextFieldVisible,
                        commentText: $commentText,
                        autoFocused: $autoFocused
                    )
                    Text(String(comments.count))
                }
                Spacer()
            }
            .background(Color.white)
            .shadow(radius: 1)
        }
        .edgesIgnoringSafeArea(.bottom)
        .withFooter()
    }
    
    private var TagsSection: some View{
        HFlow(spacing: 10) {
            ForEach(post.tags.indices, id: \.self) { index in
                ZStack(alignment: .topTrailing) {
                    
                    NavigationLink {
                        TagPostsView(tag: post.tags[index], userViewModel: userViewModel).navigationBarBackButtonHidden(true)
                    } label: {
                        Text(post.tags[index])
                            .font(.caption)
                            .fontWeight(.bold)
                            .lineLimit(1)
                            .foregroundStyle(.white)
                            .padding(.vertical, 5)
                            .padding(.horizontal, 10)
                            .background(Capsule().fill(Color.orange))
                    }

                    
                }
            }
        }
    }
    
}

// MARK: UTILITIES
func openMapsForNavigation(toLatitude latitude: CLLocationDegrees, longitude: CLLocationDegrees, locationName: String?) {
   let destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude)))
   destination.name = locationName ?? "Target Location"

   MKMapItem.openMaps(with: [destination], launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
}
