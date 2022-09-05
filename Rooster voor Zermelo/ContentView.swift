//
//  ContentView.swift
//  Rooster voor Zermelo
//
//  Created by Wisse Hes on 03/09/2022.
//

import SwiftUI
import Alamofire

struct ContentView: View {
    
    @State private var isShowingWelcomeScreen = false
    @State private var token: SavedToken? = nil
    @State private var me: ZermeloMeData? = nil
    
    var body: some View {
        Group {
            if let me = me {
                HomeView(me: me, signOut: signOut)
            } else {
                Text("Loading!")
                    .padding()
            }
        }
            .sheet(isPresented: $isShowingWelcomeScreen) {
                WelcomeView(handleClose: handleWelcomeClose)
                    .interactiveDismissDisabled()
            }
            .onAppear {
                checkSavedToken()
            }
    }
    
    func signOut() {
        TokenSaver.delete()
        self.token = nil
        self.me = nil
        self.isShowingWelcomeScreen = true
    }
    
    func handleWelcomeClose(_ savedToken: SavedToken){
        isShowingWelcomeScreen = false
        load(savedToken)
    }
    
    func checkSavedToken() {
        if let token = TokenSaver.get() {
            load(token)
        } else {
            isShowingWelcomeScreen = true
        }
    }
    
    func load(_ token: SavedToken) {
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
                    
                case .failure(let err):
                    print(err)
                }
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
