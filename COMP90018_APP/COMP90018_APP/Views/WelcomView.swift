//
//  WelcomView.swift
//  COMP90018_APP
//
//  Created by frank w on 14/9/2023.
//

import SwiftUI

struct WelcomView: View {
    @State private var naviagtePosts: Bool = false
    @State private var navigateShake: Bool = false
    @State private var isAnimating = false
    
    
    var body: some View {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.red, Color.yellow]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                                        )
                VStack(spacing: 150){
                    Text("Do you know what to eat today?")
                        .font(.largeTitle)
                        .multilineTextAlignment(.center)
                    HStack(spacing: 100){
                        
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
                        .navigationDestination(isPresented: $naviagtePosts) {
                            PostsView()
                                //.navigationBarBackButtonHidden(true)
                        }
                        .scaleEffect(isAnimating ? 1.8 : 1.0) // Apply the scale effect
                        
                        .onAppear {
                            withAnimation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                                isAnimating = true
                            }
                            
                        }
                        
                        
                        Button {
                            // Navigate to shake view for pick random restaurant
                            navigateShake = true
                        } label: {
                            Text("NO")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: 100, height: 50)
                                .background(RoundedRectangle(cornerRadius: 10).fill(Color.red))
                        }
                        .navigationDestination(isPresented: $navigateShake) {
                            ShakeView()
                        }
                        
                        .scaleEffect(isAnimating ? 1.8 : 1.0) // Apply the scale effect
                        
                        .onAppear {
                            withAnimation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                                isAnimating = true
                            }
                            
                        }
                    }
                }
            }.ignoresSafeArea()
    }
    
}

struct WelcomView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack{
            WelcomView()
        }
    }
}
