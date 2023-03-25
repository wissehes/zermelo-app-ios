//
//  AuthManager.swift
//  Rooster voor Zermelo
//
//  Created by Wisse Hes on 18/01/2023.
//

import Foundation
import Alamofire
import FirebaseAnalytics

final class AuthManager: ObservableObject {
    @Published var isLoading: Bool = true
    @Published var user: User? = nil
    
    @Published var isLoggedIn = false
    @Published var showWelcomeScreen = false
    
    init() {
        checkSavedUser()
    }
    
    func handleWelcomeScreenClosed(_ savedToken: SavedToken){
        getMeData(token: savedToken)
    }
    
    func handleLogin(school: String, code: String, addUser: Bool = false, completion: @escaping(AFError?) -> ()) {
        let codeFormatted = code.replacingOccurrences(of: " ", with: "")
        let schoolFormatted = school.trimmingCharacters(in: .whitespaces).lowercased()
        
        if school.lowercased() == "demo" {
            let params: Parameters = [
                "password": codeFormatted
            ]
            AF.request("\(API.DEMO_BASEURL)/api/token", method: .post, parameters: params)
                .validate()
            .responseDecodable(of: DemoTokenResponse.self) {response in
                switch response.result {
                case .failure(let err):
                    print(err)
                    completion(err)
                case .success(let data):
                    completion(nil)
                    let tokenData = SavedToken.init(
                        portal: data.portal,
                        access_token: data.token,
                        token_type: "Bearer",
                        expires: nil
                    )
                    self.getMeData(token: tokenData)
                }
            }
        } else {
            let params: Parameters = [
                "grant_type": "authorization_code",
                "code": codeFormatted
            ]
            
            AF.request("https://\(schoolFormatted).zportal.nl/api/v3/oauth/token", method: .post, parameters: params)
                .validate()
                .responseDecodable(of: ZermeloTokenRequest.self) { response in
                    switch response.result {
                    case .success(let data):
                        let token = SavedToken.init(institution: school, tokenInfo: data)
                        FirebaseAnalytics.Analytics.logEvent(AnalyticsEventLogin, parameters: [:])
                        if addUser {
                            self.addUser(token: token)
                        } else {
                            self.getMeData(token: token)
                        }
                        completion(nil)
                    case .failure(let err):
                        print(err)
                        completion(err)
                    }
                }
        }
    }
    
    func removeUser(user: User) {
        if user.me.code == self.user?.me.code {
            UserManager.delete(userCode: user.me.code)
            self.user = nil
            self.isLoading = true
            self.checkSavedUser()
        }
    }
    
    func signOut() {
        let users = UserManager.getAll()
        if users.count > 1 {
            guard let user = user else { return print("no user") }
            UserManager.delete(userCode: user.id)
        } else {
            guard let user = user else { return print("no user") }
            UserManager.delete(userCode: user.id)
            self.user = nil
            self.isLoading = true
            self.checkSavedUser()
        }
    }
    
    /**
     Check if there's a user saved and test the token
     */
    func checkSavedUser() {
        if let user = UserManager.getCurrent() {
            // if there's a user saved, test their token
            testToken(user)
        } else if let token = UserManager.getOld() {
            self.isLoggedIn = true
            getMeData(token: token)
            // Remove old storage
            UserManager.removeOld()
        } else {
            // else, show the welcome screen
            self.showWelcomeScreen = true
            self.isLoggedIn = false
            self.isLoading = false
        }
    }
    
    /**
     Test a user's token and update their saved data.
     */
    func testToken(_ user: User) {
        self.isLoggedIn = true
        API.fetchMe(token: user.token) { result in
            switch result {
            case .success(let data):
                // On success, update the saved user
                let save = User(token: user.token, me: data)
                UserManager.save(user: save, currentUser: true)
                self.isLoading = false
                self.isLoggedIn = true
                self.user = save
                
                Analytics.setUserProperty(user.token.portal, forName: "School")
            case .failure(let err):
                print(err)
            }
        }
    }
    
    func getMeData(token: SavedToken) {
        API.fetchMe(token: token) { result in
            switch result {
            case .success(let data):
                // On success, update the saved user
                let save = User(token: token, me: data)
                UserManager.save(user: save, currentUser: true)
                self.isLoading = false
                self.isLoggedIn = true
                self.user = save
            case .failure(let err):
                print(err)
            }
        }
    }
    
    func addUser(token: SavedToken) {
        Analytics.logEvent("Add user", parameters: ["School": token.portal])
        API.fetchMe(token: token) { result in
            switch result {
            case .success(let data):
                // On success, update the saved user
                let save = User(token: token, me: data)
                UserManager.add(user: save)
            case .failure(let err):
                print(err)
            }
        }
    }
}
