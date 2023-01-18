//
//  UserManager.swift
//  Rooster voor Zermelo
//
//  Created by Wisse Hes on 17/01/2023.
//

import Foundation

final class UserManager {
    static var oldUserDefaultsKey = "savedtoken"
    static var userDefaultsKey = "savedusers"
    static var currentUserKey = "currentuser"
    
    static func getCurrent() -> User? {
        let users = self.getAll()

        if let currentUser = UserDefaults.standard.string(forKey: self.currentUserKey) {
            guard let user = users.first(where: { $0.me.code == currentUser }) else {
                return users.first
            }
            return user
        } else {
            return users.first
        }
    }
    
    static func getAll() -> [User] {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else { return [] }
        guard let decoded = try? JSONDecoder().decode([User].self, from: data) else { return [] }
        return decoded
    }
    
    static func getOld() -> SavedToken? {
        guard let data = UserDefaults.standard.data(forKey: oldUserDefaultsKey) else { return nil }
        guard let decoded = try? JSONDecoder().decode(SavedToken.self, from: data) else { return nil }
        return decoded
    }
    
    static func save(user: User, currentUser: Bool) {
        var users = getAll()
        
        if let index = users.firstIndex(where: { $0.me.code == user.me.code }) {
            users[index] = user
        } else {
            users.append(user)
        }
        
        save(users: users)
    }
    
    static func save(users: [User]) {
        guard let encoded = try? JSONEncoder().encode(users) else { return }
        UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
    }
    
    static func delete(userCode: String) {
        let users = getAll()
        let filtered = users.filter { $0.me.code != userCode }
        save(users: users)
    }
}
