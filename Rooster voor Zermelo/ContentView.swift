//
//  ContentView.swift
//  Rooster voor Zermelo
//
//  Created by Wisse Hes on 03/09/2022.
//

import SwiftUI
import Alamofire

struct ContentView: View {
    
//    @State private var isShowingWelcomeScreen = false
//    @State private var token: SavedToken? = nil
//    @State private var me: ZermeloMeData? = nil
    
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        Group {
            if authManager.isLoggedIn {
                if authManager.isLoading {
                    ProgressView()
                } else {
                    loggedInScreen
                }
            } else {
                WelcomeView(handleClose: authManager.handleWelcomeScreenClosed)
            }
        }
    }
    
    var loggedInScreen: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Vandaag", systemImage: "calendar")
                }
            
            WeekView()
                .tabItem {
                    Label("Week", systemImage: "calendar.badge.clock")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
