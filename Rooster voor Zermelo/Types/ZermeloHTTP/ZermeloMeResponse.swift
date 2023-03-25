//
//  ZermeloMeResponse.swift
//  Rooster voor Zermelo
//
//  Created by Wisse Hes on 04/09/2022.
//

import Foundation

struct GetZermeloMe: Codable {
    let response: ZermeloMeResponse
}

struct ZermeloMeResponse: Codable {
    let data: [ZermeloMeData]
}

struct ZermeloMeData: Codable {
    let code: String
    let roles: [String]
    let firstName: String
    let prefix: String?
    let lastName: String
}
