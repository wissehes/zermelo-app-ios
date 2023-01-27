//
//  Userlist.swift
//  Rooster voor Zermelo
//
//  Created by Wisse Hes on 19/01/2023.
//

import SwiftUI

struct Userlist: View {
    
    @StateObject var viewModel = UsersViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        List {
            Section {
                ForEach(viewModel.users, id: \.id) { user in
                    Button {
                        viewModel.setCurrent(user.id)
                        dismiss()
                    } label: {
                        UserListItem(user: user)
                    }.buttonStyle(.plain)
                }
                .onDelete { index in
                    if viewModel.users.count == 1 {
                        return
                    }
                    viewModel.users.remove(atOffsets: index)
                    viewModel.save()
                }
            } footer: {
                Text("settings.account.switchUsers")
            }
        }.navigationTitle("settings.users")
            .toolbar {
                EditButton().disabled(viewModel.users.count == 1)
            }
            .analyticsScreen(name: "Userlist")
    }
}

struct Userlist_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            Userlist()
        }
    }
}
