//
//  ShakeView.swift
//  COMP90018_APP
//
//  Created by frank w on 14/9/2023.
//

import SwiftUI

struct ShakeView: View {
    @State private var categoryName: String?
    @State private var isShaking: Bool = false
    @State private var hasShaked: Bool = false
    @State private var navigatePosts: Bool = false
    
    @Environment(\.presentationMode) var presentationMode
    
    // Replace with real data
    let templateCategories = ["Chinese", "Thailand", "Korean", "Malaysia","Janpanese","Italian"]
    
    var body: some View {
        ZStack{
            Color.orange.ignoresSafeArea()
            
            VStack(spacing: 150){
                Image("shakePhone")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 350,height: 150)
                    .rotationEffect(.degrees(isShaking ? 0 : -35))
                    
                CategoryView
            }
        }
        .onShake {
            hasShaked = true
            categoryName = templateCategories.randomElement()
            // Create animation for shaking affect
            withAnimation(Animation.easeInOut(duration: 0.5)) {
                isShaking = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(Animation.easeInOut(duration: 0.5)){
                    isShaking = false
                }
            }
        }
        .toolbar{
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                }.foregroundColor(.black)
            }
        }
    }
}


// MARK: COMPONENTS
extension ShakeView {
    private var CategoryView: some View{
        Text(categoryName ?? "Find Food Post")
            .font(.largeTitle)
            .foregroundColor(.white)
            .padding()
            .frame(width: 350, height: 100)
            .background(RoundedRectangle(cornerRadius: 40).fill(hasShaked ? Color.blue : Color.gray))
            .opacity(hasShaked ? 1.0 : 0.5)
            .disabled(!hasShaked)
            .onTapGesture {
                if hasShaked{
                    navigatePosts = true
                }
            }
            .navigationDestination(isPresented: $navigatePosts) {
                TabMainView(shakeResult: categoryName ?? "").navigationBarBackButtonHidden(true)
            }
    }
}


// MARK: EXTRA SERVICES

// The notification we'll send when a shake gesture happens.
extension UIDevice {
    static let deviceDidShakeNotification = Notification.Name(rawValue: "deviceDidShakeNotification")
}

//  Override the default behavior of shake gestures to send our notification instead.
extension UIWindow {
     open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            NotificationCenter.default.post(name: UIDevice.deviceDidShakeNotification, object: nil)
        }
     }
}

// A view modifier that detects shaking and calls a function of our choosing.
struct DeviceShakeViewModifier: ViewModifier {
    let action: () -> Void

    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.deviceDidShakeNotification)) { _ in
                action()
            }
    }
}

// A View extension to make the modifier easier to use.
extension View {
    func onShake(perform action: @escaping () -> Void) -> some View {
        self.modifier(DeviceShakeViewModifier(action: action))
    }
}


struct ShakeView_Previews: PreviewProvider {
    static var previews: some View {
        ShakeView()
    }
}
