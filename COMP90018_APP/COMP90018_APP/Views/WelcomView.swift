//
//  WelcomView.swift
//  COMP90018_APP
//
//  Created by frank w on 14/9/2023.
//

import SwiftUI

struct WelcomView: View {
    @State private var naviagtePosts: Bool = false
    
    
    var body: some View {
        NavigationView {
            
            
            VStack(spacing: 150){
                Text("Do you know what to eat today?")
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
                HStack(spacing: 100){
                    NavigationLink {
                        PostsView()
                    } label: {
                        Text("posts")
                    }

                    Button {
                        // Navigate to posts view
                        naviagtePosts = true
                        
                    } label: {
                        Text("YES")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 100, height: 50)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.green))
                    }
                    Button {
                        // Navigate to shake view for pick random restaurant
                    } label: {
                        Text("NO")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 100, height: 50)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.red))
                    }
                    
                }
            }
//            .navigationDestination(isPresented: $naviagtePosts) {
//                PostsView()
//            }
        }
    }
}

struct WelcomView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomView()
    }
}
