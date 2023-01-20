//
//  UsersViewModel.swift
//  Rooster voor Zermelo
//
//  Created by Wisse Hes on 17/01/2023.
//

import Foundation

final class UsersViewModel: ObservableObject {
    @Published var users: [User] = [];
    @Published var currentUser: User?
    
    @Published var selectedUser: String?
    
    init() {
        load()
    }
    
    func load() {
        self.users = UserManager.getAll()
        self.currentUser = UserManager.getCurrent()
        self.selectedUser = currentUser?.id
    }
    
    func save() {
        UserManager.save(users: self.users)
    }
    
    func setCurrent(_ id: String) {
        UserManager.setCurrent(id: id)
    }
}
