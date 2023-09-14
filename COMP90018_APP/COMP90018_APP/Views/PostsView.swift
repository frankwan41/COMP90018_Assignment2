//
//  PostsView.swift
//  COMP90018_APP
//
//  Created by frank w on 14/9/2023.
//

import SwiftUI

struct PostsView: View {
    @State var shakeResult: String  = ""
    @State private var searchCategory: String = ""
    
    var body: some View {
        Text("This is the posts view!")
        Text("Here is your shake result: \(shakeResult)")
    }
}

//struct PostsView_Previews: PreviewProvider {
//    static var previews: some View {
//        PostsView()
//    }
//}
