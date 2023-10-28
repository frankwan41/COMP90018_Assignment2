//
//  SinglePostView.swift
//  COMP90018_APP
//
//  Created by frank w on 14/9/2023.
//

import SwiftUI
import Flow
import Kingfisher

struct SinglePostView: View {
    
    @State private var showAlert: Bool = false
    @State private var temperature: Int = 0
    @State private var cityName: String = ""
    @State private var weatherDescription: String = ""
    
    @Binding var post: Post
    @State var comments: [Comment] = []
    @State var currentUser: User? = nil
    
    @State private var isTextFieldVisible = false
    @FocusState private var autoFocused: Bool
    @State private var commentText: String = ""
    
    @State private var selectedPhotoIndex = 0
    
    @StateObject private var userViewModel = UserViewModel()
    @StateObject private var singlePostViewModel = SinglePostViewModel()
    
    @State var authorUsername: String?
    @State var profileImageURL: String?
    
    private let dateFormatter = DateFormatter()
    
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            ZStack {
                // Create a background gray effect when text editor for comment is visible
                Color.gray.opacity(isTextFieldVisible ? 0.5 : 0) // Background color
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        PostPhotoView(post: $post, selectedPhotoIndex: $selectedPhotoIndex)
                        Text(post.postTitle)
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        Text(post.content)
                            .padding(.horizontal)
                        TagsSection
                            .padding(.horizontal)
                        HStack {
                            Text(dateFormatter.string(from: post.timestamp))
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .padding(.horizontal)
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
                            // Access user profile
                        } label: {
                            HStack{
                                // Get user profile picture
                                if let urlString = profileImageURL {
                                    let url = URL(string: urlString)
                                    KFImage(url)
                                        .resizable()
                                        .frame(maxWidth: 30, maxHeight: 30)
                                        .clipped()
                                        .cornerRadius(50)
                                        .overlay(RoundedRectangle(cornerRadius: 44).stroke(Color(.label), lineWidth: 1))
                                } else {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .frame(maxWidth: 30, maxHeight: 30)
                                        .clipped()
                                        .cornerRadius(50)
                                        .overlay(RoundedRectangle(cornerRadius: 44).stroke(Color(.label), lineWidth: 1))
                                }
                                if let username = authorUsername {
                                    Text(username)
                                }
                            }
                            .foregroundColor(.black)
                            
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                let apiKey = "95e381fda50cae025af8d88dde3f5c5c"
                                getWeather(latitude: post.latitude, longitude: post.longitude, apiKey: apiKey)
                            } label: {
                                Text("Weather tip")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.pink)
                                    .padding(.horizontal, 15)
                                    .padding(.vertical, 5)
                                    .background(RoundedRectangle(cornerRadius: 20).stroke(Color.pink))
                            }
                            .alert(isPresented: $showAlert) {
                                Alert(title: Text("Weather Info for \(cityName)"),
                                      message: Text("Temperature: \(temperature)°C, Condition: \(weatherDescription)"),
                                      dismissButton: .default(Text("Got it!")))
                            }
                    }
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
            
        }
        .onAppear {
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
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
        }
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
                Spacer()
                Spacer()
                Spacer()
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
    }
    private var TagsSection: some View{
        HFlow(spacing: 10) {
            ForEach(post.tags.indices, id: \.self) { index in
                ZStack(alignment: .topTrailing) {
                    Text(post.tags[index])
                        .font(.caption)
                        .lineLimit(1)
                        .padding(.vertical, 5)
                        .padding(.horizontal, 10)
                        .background(Capsule().fill(Color.gray.opacity(0.2)))
                }
            }
        }
    }
    
}
