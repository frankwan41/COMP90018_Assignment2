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
    
    init() {
        // Changes the tab bar's background color to white
        UITabBar.appearance().barTintColor = UIColor.white
    }
    
    var body: some Scene {
        WindowGroup {
            WelcomView()
        }
    }
}

// Hide navigation bar without losing swipe back gesture in SwiftUI
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

extension UINavigationController {
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        navigationBar.isHidden = true
    }
}
