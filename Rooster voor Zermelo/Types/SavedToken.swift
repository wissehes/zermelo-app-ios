//
//  SavedToken.swift
//  Rooster voor Zermelo
//
//  Created by Wisse Hes on 04/09/2022.
//

import Foundation

struct SavedToken: Codable {
    let portal: String
    let access_token: String;
    let token_type: String;
    
    let expires: Date?
}

extension SavedToken {
    init(qrData: ZermeloQRData, tokenInfo: ZermeloTokenRequest) {
        var expireDate = Date()
        expireDate.addTimeInterval(TimeInterval(tokenInfo.expires_in))
        
        self.portal = qrData.institution;
        self.access_token = tokenInfo.access_token
        self.token_type = tokenInfo.token_type
        self.expires = expireDate
    }
    
    init(institution: String, tokenInfo: ZermeloTokenRequest) {
        var expireDate = Date()
        expireDate.addTimeInterval(TimeInterval(tokenInfo.expires_in))
        
        self.portal = institution;
        self.access_token = tokenInfo.access_token
        self.token_type = tokenInfo.token_type
        self.expires = expireDate
    }
}
