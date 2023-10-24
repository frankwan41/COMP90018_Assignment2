//
//  TabView.swift
//  COMP90018_APP
//
//  Created by frank w on 14/9/2023.
//

import SwiftUI

struct TabMainView: View {
    @State var shakeResult: String = ""
    
    @State private var isActive: Bool = false
    @State private var selectedTab: Int = 0

    
    var body: some View {
        let gradientStart = Color.orange.opacity(0.5)
        let gradientEnd = Color.orange
        let gradientBackground = LinearGradient(gradient: Gradient(colors: [gradientStart, gradientEnd]), startPoint: .top, endPoint: .bottom)
        
        NavigationStack{
            TabView{
                PostsView()
                    .navigationBarBackButtonHidden(true)
                    .tabItem {
                        Image(systemName: "fork.knife")
                        Text("Posts")
                    }
                
                ProfileView()
                    .navigationBarBackButtonHidden(true)
                    .tabItem {
                        Image(systemName: "person")
                        Text("Profile")
                    }
            }
            
            .tint(.black)
            // Customize an add button to tab items to start a post
            .overlay(
                Button(action: {
                    isActive = true
                }) {
                    Image(systemName: "plus.app.fill")
                        .resizable()
                        .frame(width: 45, height: 40)
                        .foregroundColor(.pink)
                        .cornerRadius(10)
                }
                    .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height - 118)
                    .fullScreenCover(isPresented: $isActive, content: {
                        // Your destination view goes here
                        AddPostView()
                    })
            )
        }
        
    }
}

struct PhotoView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            Text("This is the take phot page")
            Button("Dismiss") {
                presentationMode.wrappedValue.dismiss()
            }
            .padding()
        }
    }
}

struct TabView_Previews: PreviewProvider {
    static var previews: some View {
            TabMainView()
    }
}
