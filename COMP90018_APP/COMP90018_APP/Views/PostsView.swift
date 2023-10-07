//
//  PostsView.swift
//  COMP90018_APP
//
//  Created by frank w on 14/9/2023.
//

import SwiftUI

struct PostsView: View {
//    @State var shakeResult: String  = ""
    @State private var searchCategory: String = ""
    
    @AppStorage("viewDisplay") var viewSwitcher = viewPage.welcome
    @AppStorage("shakeResult") var shakeResult = ""
    
    var body: some View {
        NavigationView {
            List{
                Text("This is the posts view!")
                Text("Here is your shake result: \(shakeResult)")
                ForEach(1..<20) { index in
                    ZStack {
                        VStack(alignment:.leading){
                            Image(systemName: "photo")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .font(.largeTitle)
                            Text("This is the title of the post").font(.headline)
                            HStack{
                                Image(systemName: "person.circle")
                                Text("User name").font(.subheadline)
                                Spacer()
                                Image(systemName: "heart")
                                Text("No. Likes \(32)").font(.subheadline)
                            }
                        }
                        .padding()
                        NavigationLink(destination: SinglePostView().navigationBarBackButtonHidden(true)) {
                            EmptyView()
                        }.opacity(0)  // Making the NavigationLink invisible
                    }
                    
                }
            }
            .toolbar{
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewSwitcher = viewPage.shake
                    } label: {
                        Image(systemName: "dice")
                    }
                    
                    
                }
            }
        }
    }
}

//struct PostsView_Previews: PreviewProvider {
//    static var previews: some View {
//        PostsView()
//    }
//}
