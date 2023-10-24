//
//  SinglePostView.swift
//  COMP90018_APP
//
//  Created by frank w on 14/9/2023.
//

import SwiftUI
import Flow


struct SinglePostView: View {
    
    @State private var postLikeState = false
    @State private var postNumLikeState =  32
    
    @State private var postNumComments = 6
    @State private var isTextFieldVisible = false
    @FocusState private var autoFocused: Bool
    @State private var commentText: String = ""
    
    var tags = ["placeholder tag", "very very delicious food", "cool", "niubi", "6", "dope","very long long long long tag"]
    
    
    @State private var commentLikeStates: [Bool] = Array(repeating: false, count: 5)
    @State private var heartScale: CGFloat = 1.0
    @State private var commentNumLikeStates: [Int] = Array(repeating: 32, count: 20)
    @State private var selectedPhotoIndex = 0
    
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            ZStack {
                // Create a background gray effect when text editor for comment is visible
                Color.gray.opacity(isTextFieldVisible ? 0.5 : 0) // Background color
                                .edgesIgnoringSafeArea(.all)
                
                ScrollView{
                    VStack(alignment: .leading, spacing: 20){
                        PostPhotoView(selectedPhotoIndex: $selectedPhotoIndex)
                        Text("Titles")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Consequat ac felis donec et odio pellentesque diam. Ut lectus arcu bibendum at varius vel pharetra. Varius vel pharetra vel turpis nunc eget lorem dolor sed. Sed odio morbi quis commodo odio. Pharetra convallis posuere morbi leo urna molestie at. Nisl tincidunt eget nullam non nisi est. Nibh praesent tristique magna sit amet. Sed faucibus turpis in eu mi bibendum neque egestas congue. In arcu cursus euismod quis viverra nibh cras. Tincidunt praesent semper feugiat nibh sed. Maecenas accumsan lacus vel facilisis volutpat est velit egestas. Tristique magna sit amet purus.")
                            .padding(.horizontal)
                        TagsSection
                            .padding(.horizontal)
                        HStack{
                            Text("TimeStamp")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                            Spacer()
                        }
                        Divider()
                        
                        CommentsSection(commentLikeStates: $commentLikeStates, heartScale: $heartScale, commentNumLikeStates: $commentNumLikeStates)
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
                
                // Disable the text editor when tap screen
                if (isTextFieldVisible) {
                    Button(action: {
                        autoFocused = false
                        isTextFieldVisible = false
                    }){
                        Color.clear.ignoresSafeArea()
                    }
                }

                if isTextFieldVisible{
                    CommentTextField(commentText: $commentText, isTextFieldVisible: $isTextFieldVisible, autoFocused: $autoFocused)
                }else{
                    BottomBar
                }
                
            }
            
        }
        
        
    }
}


// MARK: COMPONENTS

extension SinglePostView{
    private var BottomBar: some View {
        VStack {
            
                    Spacer()  // Push the HStack to the bottom of the ZStack
                    HStack {
                        Spacer()
                        HStack{
                            SinglePostLikeBtn(likeState: $postLikeState, heartScale: $heartScale, numLikeState: $postNumLikeState)
                            Text("\(postNumLikeState)")
                        }
                        // Pushes the two buttons apart
                        Spacer()
                        Spacer()
                        Spacer()
                        HStack{
                            SinglePostCommentBtn(isTextFieldVisible: $isTextFieldVisible, commentText: $commentText, autoFocused: $autoFocused)
                            Text("\(postNumComments)")
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
            ForEach(tags.indices, id: \.self) {index in
                ZStack(alignment: .topTrailing) {
                    Text(tags[index])
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

struct SinglePostLikeBtn: View{
        @Binding var likeState: Bool
        @Binding var heartScale: CGFloat
        @Binding var numLikeState: Int
        @StateObject var userViewModel = UserViewModel()
        @State private var showLoginAlert = false
        
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
                if (userViewModel.isLoggedIn){
                    toggleLikes()
                }
                else{
                    showLoginAlert = true
                }
                
                
            } label: {
                Image(systemName: likeState ? "heart.fill" : "heart")
                    .resizable()
                    .frame(width: 30, height: 25)
                    .scaleEffect(heartScale)
                    .foregroundColor(likeState ? .red : .black)
                    .padding(.vertical)
            }
            .alert(isPresented: $showLoginAlert) {
                Alert(
                    title: Text("Login Required"),
                    message: Text("You need to log in to like posts."),
                    dismissButton: .default(Text("OK"))
                    
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
        
        // Toggle number of likes, +1 / -1
        func toggleLikes(){
            likeState.toggle()
            if likeState {
                numLikeState += 1
            }else{
                numLikeState -= 1
            }
        }
    
}

struct SinglePostCommentBtn: View {
    @Binding var isTextFieldVisible: Bool
    @Binding var commentText: String
    @FocusState.Binding var autoFocused: Bool
    @StateObject var userViewModel = UserViewModel()
    @State private var showLoginAlert = false
    
    var body: some View {
        Button(action: {
            // Handle message button action
            if(userViewModel.isLoggedIn){
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


struct CommentTextField: View{
    @Binding var commentText: String
    @Binding var isTextFieldVisible: Bool
    @FocusState.Binding var autoFocused: Bool
    
    let lineHeight: CGFloat = 30 // Approximate height for a line of text
    let maxCharactersPerLine: Int = 55 // Measured
    @State private var editorHeight: CGFloat
    
    init(commentText: Binding<String>, isTextFieldVisible: Binding<Bool>, autoFocused: FocusState<Bool>.Binding) {
        self._commentText = commentText
        self._isTextFieldVisible = isTextFieldVisible
        self._autoFocused = autoFocused
        
        // Initialize the height of text editor
        let calculatedHeight = Self.calculateEditorHeight(value: commentText.wrappedValue, maxCharactersPerLine: maxCharactersPerLine, lineHeight: lineHeight)
        _editorHeight = State(initialValue: calculatedHeight)
    }

    
    
    var body: some View{
        VStack {
            Spacer()
            HStack {
                    TextEditor(text: $commentText)
                        .onChange(of: commentText) { value in
                            editorHeight = Self.calculateEditorHeight(value: value, maxCharactersPerLine: maxCharactersPerLine, lineHeight: lineHeight)
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
                    commentText = ""
                    isTextFieldVisible = false
                    autoFocused = false
                    print("button clicked")
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
    @Binding var commentLikeStates: [Bool]
    @Binding var heartScale: CGFloat
    @Binding var commentNumLikeStates: [Int]
    
    var body: some View {
        VStack(alignment:.leading){
            HStack{
                Text("384 Comments")
                    .font(.headline)
                    .fontWeight(.thin)
                    .padding(.horizontal)
                Spacer()
            }.padding(.bottom)
            
            ForEach(1..<5) { index in
                SingleComment(index: index, commentLikeStates: $commentLikeStates, heartScale: $heartScale, commentNumLikeStates: $commentNumLikeStates)
                    .padding()
                Divider()
            }
            
        }
    }
}

struct SingleComment: View {
    let index: Int
    @Binding var commentLikeStates: [Bool]
    @Binding var heartScale: CGFloat
    @Binding var commentNumLikeStates: [Int]
    @StateObject var userViewModel = UserViewModel() // <-- Add this line
    @State private var showLoginSheet = false       // <-- Add this line
    
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
                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.")
                    .padding(.bottom)
                Image(systemName: "photo")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
            // End section: contains like button and number of likes
            VStack{
                LikeButton(index: index, likeStates: $commentLikeStates,
                           heartScale: $heartScale,
                           numLikeStates: $commentNumLikeStates,
                           isLoggedIn: $userViewModel.isLoggedIn,
                           showLoginSheet:$showLoginSheet)
                Text("\(commentNumLikeStates[index])")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
            
        }
    }
}

struct PostPhotoView: View {
    @Binding var selectedPhotoIndex: Int
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedPhotoIndex) {
                ForEach(1..<5) {_ in
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .padding()
                }
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .frame(width: UIScreen.main.bounds.width, height: 300)
        
        GeometryReader { geo in
            HStack(spacing: 8) {
                ForEach(1..<5, id: \.self) { index in
                    Circle()
                        .frame(width: 8, height: 8)
                        .foregroundColor(selectedPhotoIndex == index-1 ? .pink : .gray)
                }
            }
            .position(x: geo.size.width / 2, y: geo.size.height - 20)  // Adjust y value to position
        }
    }
}


struct SinglePostView_Previews: PreviewProvider {
    static var previews: some View {
        SinglePostView()
    }
}
