//
//  FooterViewModifier.swift
//  COMP90018_APP
//
//  Created by frank w on 6/11/2023.
//

import SwiftUI

struct FooterViewModifier: ViewModifier {
    let appName: String = "What2Eat"

    func body(content: Content) -> some View {
        content
            .overlay(
                VStack {
                    Spacer()
                    Text("@\(appName)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding()
                }
                    .offset(y:40)
            , alignment: .bottom)
    }
}

extension View {
    func withFooter() -> some View {
        self.modifier(FooterViewModifier())
    }
}
