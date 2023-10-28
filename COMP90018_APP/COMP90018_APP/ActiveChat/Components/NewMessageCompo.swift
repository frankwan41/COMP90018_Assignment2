//
//  NewMessageCompo.swift
//  COMP90018_APP
//
//  Created by Junran Lin on 28/10/2023.
//
import SwiftUI
import Kingfisher
import CoreLocation

struct NewMessageCompo: View {
    var user: User
    
    @ObservedObject var newMessageViewModel: NewMessageViewModel
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a, M/d/yy"
        return formatter
    }
    
    
    var body: some View {
        HStack(spacing: 16) {
            
            if !user.profileImageURL.isEmpty{
                KFImage(URL(string: user.profileImageURL))
                    .resizable()
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
            }else{
                Image(systemName: "person.circle")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
            }
            
            
            
            VStack(alignment: .leading, spacing: 8) {
                Text(user.userName)
                    .font(.headline)
                    .foregroundColor(.black)
                
                Text(user.email)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            if let currentUser = newMessageViewModel.currentUser{
                
                VStack{
                    let distance = calculateDistance()
                    
                    if distance < 1000 {
                        // If less than 1000 meters, show in meters
                        Text("\(String(format: "%.0f", distance)) m").fontWeight(.bold).font(.callout).tint(.orange)
                    } else {
                        // If 1 km or more, convert to kilometers and show one decimal place
                        let distanceInKilometers = distance / 1000
                        Text("\(String(format: "%.0f", distanceInKilometers)) km").fontWeight(.bold).font(.callout).tint(.orange)
                    }
                    
                    Text(dateFormatter.string(from: user.locationTimestamp.dateValue()))
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
            }
            
        }
        .padding(16)
    }
    
    func calculateDistance() -> CLLocationDistance{
        let currentUserCoordinate = CLLocation(latitude: newMessageViewModel.currentUser?.currentLatitude ?? 0, longitude: newMessageViewModel.currentUser?.currentLongitude ?? 0)
        let selectedUserCoordinate = CLLocation(latitude: user.currentLatitude, longitude: user.currentLongitude)
        return currentUserCoordinate.distance(from: selectedUserCoordinate).rounded()
    }
}



//#Preview {
//    NewMessageCompo()
//}
