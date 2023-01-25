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
        
#if !targetEnvironment(simulator)
        FirebaseApp.configure()
#endif
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        
        return true
    }
}


@main
struct Rooster_voor_ZermeloApp: App {
    @StateObject var authManager = AuthManager()
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @Environment(\.scenePhase) private var phase
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
        }
        .onChange(of: phase) { newPhase in
            switch newPhase {
            case .background: BackgroundTasksController.scheduleAppRefresh()
            default: break
            }
        }.backgroundTask(.appRefresh("notificationrefresh")) {
            let result = await API.getLiveScheduleAsync()
            guard case .success(let data) = result else { return }
            await NotificationsManager.scheduleNotifications(data)
        }
    }
}
