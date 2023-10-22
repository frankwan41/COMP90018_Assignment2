//
//  WelcomView.swift
//  COMP90018_APP
//
//  Created by frank w on 14/9/2023.
//

enum viewPage: String{
    case welcome = "welcome"
    case tab = "tab"
    case shake = "shake"
}


import SwiftUI

struct WelcomView: View {

    @AppStorage("viewDisplay") var viewSwitcher = viewPage.welcome
    
    init(){
        viewSwitcher = viewPage.welcome
    }
    
    
    var body: some View {
        VStack{
            if viewSwitcher == viewPage.welcome{
                welcomeMainView()
            }else if viewSwitcher == viewPage.tab{
                TabMainView()
                //TODO: Change the color scheme if neccessary
                    .preferredColorScheme(.light)
            }else if viewSwitcher == viewPage.shake{
                ShakeView()
            }
        }
    }
    
}

struct welcomeMainView: View {
    
    @AppStorage("viewDisplay") var viewSwitcher = viewPage.welcome
    
    @State private var isAnimating = false
    
    var body: some View{
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
                        viewSwitcher = viewPage.tab
                    } label: {
                        Text("YES")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 100, height: 50)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.green))
                    }
                    .scaleEffect(isAnimating ? 1.8 : 1.0) // Apply the scale effect
                    
                    .onAppear {
                        withAnimation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                            isAnimating = true
                        }
                        
                    }
                    
                    
                    Button {
                        // Navigate to shake view for pick random restaurant
                        viewSwitcher = viewPage.shake
                    } label: {
                        Text("NO")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 100, height: 50)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.red))
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
