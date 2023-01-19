//
//  SettingsViewModel.swift
//  Rooster voor Zermelo
//
//  Created by Wisse Hes on 19/01/2023.
//

import Foundation

final class SettingsViewModel: ObservableObject {
    @Published var user: User?
    
    init() {
        load()
    }
    
    func load() {
        self.user = UserManager.getCurrent()
    }
}
