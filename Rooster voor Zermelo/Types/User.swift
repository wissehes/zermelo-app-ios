//
//  User.swift
//  Rooster voor Zermelo
//
//  Created by Wisse Hes on 17/01/2023.
//

import Foundation

struct User: Codable {
    let token: SavedToken
    var me: ZermeloMeData
}
