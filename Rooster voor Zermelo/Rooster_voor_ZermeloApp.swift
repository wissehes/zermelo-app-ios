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
    private let actionService = ActionService.shared
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
#if !targetEnvironment(simulator)
        FirebaseApp.configure()
        FirebaseConfiguration.shared.setLoggerLevel(.error)
        
        guard let sentry_dsn = Bundle.main.infoDictionary?["SENTRY_DSN"] as? String else {
            print("NO SENTRY DSN")
            return true
        }
        SentrySDK.start { options in
            options.dsn = sentry_dsn
            options.tracesSampleRate = 0.5
        }
#endif
        
        return true
    }
    
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        if let shortcutItem = options.shortcutItem {
            actionService.handleAction(shortcutItem: shortcutItem)
        }
        
        let configuration = UISceneConfiguration(
            name: connectingSceneSession.configuration.name,
            sessionRole: connectingSceneSession.role
        )
        configuration.delegateClass = SceneDelegate.self
        return configuration
    }
    
}

class SceneDelegate: NSObject, UIWindowSceneDelegate {
  private let actionService = ActionService.shared

  func windowScene(
    _ windowScene: UIWindowScene,
    performActionFor shortcutItem: UIApplicationShortcutItem,
    completionHandler: @escaping (Bool) -> Void
  ) {
    actionService.handleAction(shortcutItem: shortcutItem)
    completionHandler(true)
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
                .environmentObject(ActionService.shared)
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
