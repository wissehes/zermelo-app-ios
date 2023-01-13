//
//  ContentView.swift
//  Rooster voor Zermelo
//
//  Created by Wisse Hes on 03/09/2022.
//

import SwiftUI
import Alamofire
import FirebaseAnalytics

struct ContentView: View {
    
//    @State private var isShowingWelcomeScreen = false
//    @State private var token: SavedToken? = nil
//    @State private var me: ZermeloMeData? = nil
    
    @EnvironmentObject var authManager: AuthManager
    
    init() {
        Analytics.logEvent(AnalyticsEventAppOpen, parameters: [:])

    }
    
    var body: some View {
        Group {
            if authManager.isLoggedIn {
                if authManager.isLoading {
                    ProgressView()
                } else {
                    loggedInScreen
                }
            } else {
                WelcomeView()
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

//import SwiftUI
//
//import FirebaseCore
//
//
//class AppDelegate: NSObject, UIApplicationDelegate {
//
//  func application(_ application: UIApplication,
//
//                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
//
//    FirebaseApp.configure()
//
//    return true
//
//  }
//
//}
//
//
//@main
//
//struct YourApp: App {
//
//  // register app delegate for Firebase setup
//
//  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
//
//
//  var body: some Scene {
//
//    WindowGroup {
//
//      NavigationView {
//
//        ContentView()
//
//      }
//
//    }
//
//  }
//
//}
