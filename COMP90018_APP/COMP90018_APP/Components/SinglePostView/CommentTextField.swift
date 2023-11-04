//
//  CommentTextField.swift
//  COMP90018_APP
//
//  Created by Bowen Fan on 28/10/2023.
//

import SwiftUI

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
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        singlePostViewModel.getPostComments(postID: post.id) { comments in
                            if let fetchedComments = comments {
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
            .padding(.horizontal, post.imageURLs.count > 0 ? 15 : 0)
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
