//
//  TabView.swift
//  COMP90018_APP
//
//  Created by frank w on 14/9/2023.
//

import SwiftUI

struct TabMainView: View {
    var body: some View {
        TabView{
            PostsView()
                .tabItem {
                    Image(systemName: "fork.knife")
                    Text("Posts")
                }
            ProfileView()
                .tabItem {
                    Image(systemName: "person")
                    Text("Profile")
                }
        }
        
    }
}

struct TabView_Previews: PreviewProvider {
    static var previews: some View {
        TabMainView()
    }
}
