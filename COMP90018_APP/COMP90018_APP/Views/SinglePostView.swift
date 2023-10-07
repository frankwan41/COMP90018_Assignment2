//
//  SinglePostView.swift
//  COMP90018_APP
//
//  Created by frank w on 14/9/2023.
//

import SwiftUI

struct SinglePostView: View {
    
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            ScrollView{
                VStack{
                    Image(systemName: "photo")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .font(.largeTitle)
                    Text("Titles")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Consequat ac felis donec et odio pellentesque diam. Ut lectus arcu bibendum at varius vel pharetra. Varius vel pharetra vel turpis nunc eget lorem dolor sed. Sed odio morbi quis commodo odio. Pharetra convallis posuere morbi leo urna molestie at. Nisl tincidunt eget nullam non nisi est. Nibh praesent tristique magna sit amet. Sed faucibus turpis in eu mi bibendum neque egestas congue. In arcu cursus euismod quis viverra nibh cras. Tincidunt praesent semper feugiat nibh sed. Maecenas accumsan lacus vel facilisis volutpat est velit egestas. Tristique magna sit amet purus.")
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        // Access user profile
                    } label: {
                        Image(systemName: "person.circle.fill")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button{
                        // Share / Other manipulations
                    }label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
        }
        
    }
}

struct SinglePostView_Previews: PreviewProvider {
    static var previews: some View {
        SinglePostView()
    }
}
