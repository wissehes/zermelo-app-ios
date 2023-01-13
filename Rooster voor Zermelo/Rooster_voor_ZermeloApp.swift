//
//  Rooster_voor_ZermeloApp.swift
//  Rooster voor Zermelo
//
//  Created by Wisse Hes on 03/09/2022.
//

import SwiftUI
//import FirebaseAnalytics
//import FirebaseCore
import FirebaseCore
import FirebaseCrashlytics
import FirebaseAnalytics


class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        FirebaseApp.configure()
        FirebaseConfiguration.shared.setLoggerLevel(.max)
        
        return true
    }
}


@main
struct Rooster_voor_ZermeloApp: App {
    @StateObject var authManager = AuthManager()
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
        }
    }
}
