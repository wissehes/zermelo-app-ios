//
//  SettingsViewModel.swift
//  Rooster voor Zermelo
//
//  Created by Wisse Hes on 17/01/2023.
//

import Foundation

final class SettingsViewModel: ObservableObject {
    @Published var users: [User] = [];
    
    init() {
        self.users = UserManager.getAll()
    }
}
