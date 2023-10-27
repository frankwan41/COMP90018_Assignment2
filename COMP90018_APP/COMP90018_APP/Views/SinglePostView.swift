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
    
    @State var post: Post
    @State var comments: [Comment] = []
    
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
                        
                        CommentsSection(comments: $comments)
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
            
        }
        .onAppear {
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
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
                    LikeButton(
                        isSinglePostView: true,
                        isLoggedIn: $userViewModel.isLoggedIn,
                        post: $post
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

struct SinglePostCommentButton: View {
    
    @Binding var post: Post
    @Binding var comments: [Comment]
    @Binding var isTextFieldVisible: Bool
    @Binding var commentText: String
    @FocusState.Binding var autoFocused: Bool
    @StateObject var userViewModel = UserViewModel()
    @State private var showLoginAlert = false
    
    var body: some View {
        Button(action: {
            // Handle message button action
            if (userViewModel.isLoggedIn){
                isTextFieldVisible = true
                autoFocused = true
            }
            else{
                showLoginAlert = true
            }
            
        }) {
            Image(systemName: "ellipsis.message")
                .resizable()
                .frame(width: 27, height: 27)
                .foregroundColor(.black)
                .padding(.vertical)
        }
        .alert(isPresented: $showLoginAlert) {
            Alert(
                title: Text("Login Required"),
                message: Text("You need to log in to comment posts."),
                dismissButton: .default(Text("OK"))
                
            )
        }
    }
}


struct CommentTextField: View {
    
    @Binding var post: Post
    @Binding var comments: [Comment]
    @Binding var commentText: String
    @Binding var isTextFieldVisible: Bool
    @FocusState.Binding var autoFocused: Bool
    
    let lineHeight: CGFloat = 30 // Approximate height for a line of text
    let maxCharactersPerLine: Int = 55 // Measured
    @State private var editorHeight: CGFloat
    
    @StateObject private var singlePostViewModel = SinglePostViewModel()
    
    init(post: Binding<Post>, comments: Binding<[Comment]>, commentText: Binding<String>, isTextFieldVisible: Binding<Bool>, autoFocused: FocusState<Bool>.Binding) {
        self._post = post
        self._comments = comments
        self._commentText = commentText
        self._isTextFieldVisible = isTextFieldVisible
        self._autoFocused = autoFocused
        
        // Initialize the height of text editor
        let calculatedHeight = Self.calculateEditorHeight(value: commentText.wrappedValue, maxCharactersPerLine: maxCharactersPerLine, lineHeight: lineHeight)
        _editorHeight = State(initialValue: calculatedHeight)
    }

    
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                TextEditor(text: $commentText)
                    .onChange(of: commentText) { value in
                        editorHeight = Self.calculateEditorHeight(
                            value: value,
                            maxCharactersPerLine: maxCharactersPerLine,
                            lineHeight: lineHeight
                        )
                    }
                    .focused($autoFocused) // This is used to set the focus on the TextField
                    .frame(height: editorHeight)
                    .scrollContentBackground(.hidden)
                    .background(.gray.opacity(0.04))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray, lineWidth: 0.5))
                    .padding()
                
                Button {
                    // Send the comment
                    singlePostViewModel.addComment(postID: post.id, content: commentText)
                    commentText = ""
                    isTextFieldVisible = false
                    autoFocused = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        singlePostViewModel.getPostComments(postID: post.id) { comments in
                            if let fetchedComments = comments {
                                print(fetchedComments)
                                self.comments = fetchedComments
                            }
                        }
                    }
                    
                } label: {
                    Text("Send")
                        .padding(.all, 10)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(20)
                }.padding(.trailing,10)
            }
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .padding(.horizontal)
        }
    }
    
    // Calculate the text editor height
    static func calculateEditorHeight(value: String, maxCharactersPerLine: Int, lineHeight: CGFloat) -> CGFloat {
        let numberOfLines = max(value.split(whereSeparator: { $0.isNewline }).count, Int(ceil(Double(value.count) / Double(maxCharactersPerLine))))
        let calculatedHeight = CGFloat(numberOfLines) * lineHeight
        // Limit the height to a maximum of 90
        return min(90, max(lineHeight, calculatedHeight))
    }
}


struct CommentsSection: View {
    
    @Binding var comments: [Comment]
    
    var body: some View {
        VStack(alignment:.leading){
            HStack{
                Text("\(comments.count) Comments")
                    .font(.headline)
                    .fontWeight(.thin)
                    .padding(.horizontal)
                Spacer()
            }.padding(.bottom)
            
            if comments.count > 0 {
                ForEach($comments, id: \.commentID) { comment in
                    SingleComment(comment: comment).padding()
                    Divider()
                }
            }
        }
    }
}

struct SingleComment: View {
    
    @Binding var comment: Comment
    
    @State private var showLoginSheet = false
    
    @State var profileImageURL: String?
    @State var authorUsername: String?
    
    @StateObject var userViewModel = UserViewModel()
    
    var body: some View {

        HStack(alignment: .top, spacing: 10) {
            // Front section: contains only user profile photo
            if let urlString = profileImageURL {
                let url = URL(string: urlString)
                KFImage(url)
                    .resizable()
                    .frame(maxWidth: 35, maxHeight: 35)
                    .clipped()
                    .cornerRadius(50)
                    .overlay(RoundedRectangle(cornerRadius: 44).stroke(Color(.label), lineWidth: 1))
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(maxWidth: 35, maxHeight: 35)
                    .clipped()
                    .cornerRadius(50)
                    .overlay(RoundedRectangle(cornerRadius: 44).stroke(Color(.label), lineWidth: 1))
            }
            
            // Middle section: contains username, comments, possible image comment
            VStack(alignment:.leading, spacing: 5){
                if let username = authorUsername {
                    Text(username)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Text(comment.content)
                    .padding(.bottom)
            }
            // End section: contains like button and number of likes
            Spacer() // Aligns the following UI to the right
            VStack {
                LikeButtonComment(isLoggedIn: $userViewModel.isLoggedIn, comment: $comment)
                Text(String(comment.likes))
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
            
        }
        .onAppear {
            userViewModel.getUser(userUID: comment.userID) { user in
                if let user = user {
                    authorUsername = user.userName
                    profileImageURL = user.profileImageURL
                } else {
                    authorUsername = nil
                    profileImageURL = nil
                }
            }
        }
    }
}

struct PostPhotoView: View {
    
    @Binding var post: Post
    @Binding var selectedPhotoIndex: Int
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedPhotoIndex) {
                if post.imageURLs.count > 0 {
                    ForEach (0 ..< post.imageURLs.count) { index in
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

struct LikeButtonComment: View {
    
    @Binding var isLoggedIn: Bool
    @Binding var comment: Comment
    @State var user: User? = nil

    @State var heartScale: CGFloat = 1.0
    @State var showLoginSheet: Bool = false
    @State private var showLoginAlert = false
    
    @State var isLiked: Bool = false
    
    @StateObject var userViewModel = UserViewModel()
    @StateObject var singlePostViewModel = SinglePostViewModel()
    
    var body: some View {
        Button {
            if isLoggedIn {
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
            } else {
                showLoginAlert = true
            }
        } label: {
            Image(systemName: isLiked ? "heart.fill" : "heart")
                .scaleEffect(heartScale)
                .foregroundColor(isLiked ? .red : .gray)
        }
        .alert(isPresented: $showLoginAlert) {
            Alert(
                title: Text("Login Required"),
                message: Text("You need to be logged in to like posts."),
                dismissButton: .default(Text("OK"), action: {
                    showLoginSheet = true
                })
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            userViewModel.getCurrentUser { user in
                if let user = user {
                    self.user = user
                    isLiked = user.likedCommentsIDs.contains(comment.commentID)
                }
            }
        }
        // TODO: detect login information with .onChange()
        .onChange(of: userViewModel.isLoggedIn, perform: { newValue in
            if !newValue {
                isLiked = false
            }
        })
    }
    
    // Toggle number of likes, +1 / -1
    func toggleLikes() {
        if var currentUser = user {
            isLiked.toggle()
            if isLiked {
                currentUser.likedCommentsIDs.append(comment.commentID)
                comment.likes += 1
            } else {
                currentUser.likedCommentsIDs.removeAll { $0 == comment.commentID }
                comment.likes -= 1
            }
            userViewModel.clickCommentLikeButton(commentID: comment.commentID)
            singlePostViewModel.updateCommentLikes(commentID: comment.commentID, newLikes: comment.likes)
        }
    }
}
