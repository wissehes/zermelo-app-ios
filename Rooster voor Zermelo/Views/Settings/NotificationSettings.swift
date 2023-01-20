//
//  NotificationSettings.swift
//  Rooster voor Zermelo
//
//  Created by Wisse Hes on 20/01/2023.
//

import SwiftUI

struct NotificationSettings: View {
    @StateObject var viewModel = NotificationViewModel()
    
    
    var body: some View {
        Picker("Account voor meldingen", selection: $viewModel.selected) {
            ForEach(viewModel.users, id: \.id) { user in
                Text(user.me.firstName + " " + user.me.lastName)
                    .tag(user as User?)
            }
        }.onChange(of: viewModel.selected) { _ in
            viewModel.update()
        }
        
    }
}

struct NotificationSettings_Previews: PreviewProvider {
    static var previews: some View {
        NotificationSettings()
    }
}

final class NotificationViewModel: ObservableObject {
    @Published var selected: User?
    @Published var users: [User] = []
    
    init() {
        load()
    }
    
    func load() {
        self.selected = UserManager.getCurrentNotificationsUser()
        self.users = UserManager.getAll()
    }
    
    func update() {
        guard let selected = selected else { return }
        NotificationsManager.setNotificationUser(id: selected.id)
        NotificationsManager.removeAllNotifications()
    }
}
