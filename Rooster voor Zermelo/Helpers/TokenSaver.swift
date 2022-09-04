//
//  TokenSaver.swift
//  Rooster voor Zermelo
//
//  Created by Wisse Hes on 04/09/2022.
//

import Foundation

struct TokenSaver {
    static var userDefaultsKey = "savedtoken"
    
    static func save(tokendata: SavedToken) {
        if let encoded = try? JSONEncoder().encode(tokendata) {
            UserDefaults.standard.set(encoded, forKey: self.userDefaultsKey)
        }
    }
    
    static func get() -> SavedToken? {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else { return nil }
        guard let decoded = try? JSONDecoder().decode(SavedToken.self, from: data) else { return nil }
        return decoded
    }
    
    static func delete() {
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }
}
