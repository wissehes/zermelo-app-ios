//
//  ZermeloTokenRequest.swift
//  Rooster voor Zermelo
//
//  Created by Wisse Hes on 03/09/2022.
//

import Foundation

struct ZermeloTokenRequest: Codable {
    let access_token: String
    let token_type: String
    let expires_in: Int
}
