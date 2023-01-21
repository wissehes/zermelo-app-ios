//
//  UserListItem.swift
//  Rooster voor Zermelo
//
//  Created by Wisse Hes on 17/01/2023.
//

import SwiftUI

struct UserListItem: View {
    
    var user: User    
    var initials: String {
        return String(user.me.firstName.prefix(1) + user.me.lastName.prefix(1))
    }
    
    var body: some View {
        HStack(alignment: .center) {
            HStack(alignment: .center) {
                Text(initials)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .frame(width: 35, height: 35, alignment: .center)
                    .padding()
                    .overlay(
                        Circle()
                            .stroke(Color.accentColor, lineWidth: 5)
                            .padding(6)
                    )
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text("\(user.me.firstName) \(user.me.lastName)")
                    .font(.title3)
                    .bold()
                Text("\(user.me.code) - \(user.token.portal)")
                    .font(.system(.subheadline, design: .monospaced))
            }
        }
    }
}

struct UserListItem_Previews: PreviewProvider {
    static var previews: some View {
        List {
            Button {} label: {
                Label("settings.users.add", systemImage: "person.crop.circle.badge.plus")
                    .symbolRenderingMode(.multicolor)
            }
            
            Button(role: .destructive) { } label: {
                Label("settings.users.logout", systemImage: "person.crop.circle.badge.xmark")
                    .symbolRenderingMode(.multicolor)
            }
            Button {
                
            } label: {
                UserListItem(user: User.example)
            }
        }
    }
}
