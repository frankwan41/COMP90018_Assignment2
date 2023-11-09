//
//  COMP90018_APPApp.swift
//  COMP90018_APP
//
//  Created by Yc W on 7/9/2023.
//

import SwiftUI
import UIKit


@main
struct COMP90018_APPApp: App {
    
    @AppStorage("viewDisplay") var viewSwitcher = viewPage.welcome
    
    init() {
        // Changes the tab bar's background color to white
        UITabBar.appearance().barTintColor = UIColor.white
        viewSwitcher = .welcome
    }
    
    var body: some Scene {
        WindowGroup {
            WelcomView().environmentObject(SpeechRecognizerViewModel())
                .environmentObject(UserViewModel())
                .preferredColorScheme(.light)
        }
    }
}

// Hide navigation bar without losing swipe back gesture in SwiftUI (currently doesn't work on IOS 17)
// https://stackoverflow.com/a/60067869
//extension UINavigationController: UIGestureRecognizerDelegate {
//    override open func viewDidLoad() {
//        super.viewDidLoad()
//        interactivePopGestureRecognizer?.delegate = self
//    }
//
//    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//        return viewControllers.count > 1
//    }
//}
