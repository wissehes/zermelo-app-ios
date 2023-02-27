//
//  Rooster_voor_ZermeloApp.swift
//  Rooster voor Zermelo
//
//  Created by Wisse Hes on 03/09/2022.
//

import SwiftUI
import FirebaseCore
import FirebaseAnalytics
import Sentry


class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
#if !targetEnvironment(simulator)
        FirebaseApp.configure()
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        
        guard let sentry_dsn = Bundle.main.infoDictionary?["SENTRY_DSN"] as? String else {
            print("NO SENTRY DSN")
            return true
        }

        SentrySDK.start { options in
            options.dsn = sentry_dsn
            
//            options.debug = true // Enabled debug when first installing is always helpful
            
            // Set tracesSampleRate to 1.0 to capture 100% of transactions for performance monitoring.
            // We recommend adjusting this value in production.
            options.tracesSampleRate = 0.5
        }
#endif

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
