//
//  UserManager.swift
//  Rooster voor Zermelo
//
//  Created by Wisse Hes on 17/01/2023.
//

import Foundation

enum UserState {
    case noUsers
    case noneSelected
    case user(user: User)
}

final class UserManager {
    static var oldUserDefaultsKey = "savedtoken"
    static var userDefaultsKey = "savedusers"
    static var currentUserKey = "currentuser"
    static var currentNotifUserKey = "notificationsuser"
    
    static func getCurrent() -> User? {
        let users = self.getAll()
        if let currentUser = UserDefaults.standard.string(forKey: self.currentUserKey) {
            print("current user \(currentUser)")
            guard let user = users.first(where: { $0.id == currentUser }) else {
                print("curernt user id doesnt match")
                return users.first
            }
            return user
        } else {
            print("No ucurrent user")
            return users.first
        }
    }
    
    static func getCurrentNotificationsUser() -> User? {
        let users = self.getAll()
        if let currentUser = UserDefaults.standard.string(forKey: self.currentNotifUserKey) {
            guard let user = users.first(where: { $0.id == currentUser }) else {
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
        
        if let index = users.firstIndex(where: { $0.id == user.id }) {
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
    
    static func add(user: User) {
        // Filter users so we don't end up with duplicate users.
//        var users = getAll().filter { $0.me.code != user.me.code }
        var users = getAll()
        
        users.append(user)
        
        save(users: users)
    }
    
    static func delete(userCode: String) {
        let users = getAll()
        let filtered = users.filter { $0.id != userCode }
        save(users: filtered)
    }
    
    static func setCurrent(id: String) {
        print("Set current user to: \(id)")
        UserDefaults.standard.set(id, forKey: self.currentUserKey)
    }
}
