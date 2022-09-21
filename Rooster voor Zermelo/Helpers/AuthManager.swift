//
//  AuthManager.swift
//  Rooster voor Zermelo
//
//  Created by Wisse Hes on 21/09/2022.
//

import Foundation
import Alamofire

class AuthManager: ObservableObject {
    @Published var isLoading = true
    @Published var me: ZermeloMeData? = nil
    @Published var token: SavedToken? = nil
    
    @Published var isLoggedIn = false
    @Published var showWelcomeScreen = false
    
    init() {
        checkSavedToken()
    }
    
    func signOut() {
        TokenSaver.delete()
        me = nil
        token = nil
        isLoggedIn = false
        showWelcomeScreen = true
    }
    
    func handleWelcomeScreenClosed(_ savedToken: SavedToken){
        self.token = savedToken
        self.load(savedToken)
    }
    
    private func checkSavedToken() {
        if let token = TokenSaver.get() {
            load(token)
            self.isLoggedIn = true
        } else {
            showWelcomeScreen = true
            self.isLoggedIn = false
        }
    }
    
    private func load(_ token: SavedToken) {
        self.token = token
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token.access_token)"
        ]
        
        AF.request("https://\(token.portal).zportal.nl/api/v3/users/~me", headers: headers)
            .validate()
            .responseDecodable(of: GetZermeloMe.self) { response in
                switch response.result {
                case .success(let data):
                    guard let data = data.response.data.first else { return }
                    self.me = data
                    self.isLoading = false
                    self.isLoggedIn = true
                    
                case .failure(let err):
                    print(err)
                }
            }
    }
}
