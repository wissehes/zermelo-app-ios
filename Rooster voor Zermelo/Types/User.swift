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

extension User {
    var id: String {
        return self.me.code + self.token.access_token
    }
}

extension User {
    static let example = User(
        token: SavedToken(
            portal: "amadeus",
            access_token: "aaa",
            token_type: "Bearer",
            expires: nil
        ),
        me: ZermeloMeData(
            code: "10000",
            roles: ["leerling"],
            firstName: "Wisse", lastName: "Hes"
        )
    )
}
