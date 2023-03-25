//
//  ContentView.swift
//  Rooster voor Zermelo
//
//  Created by Wisse Hes on 03/09/2022.
//

import SwiftUI
import Alamofire
import FirebaseAnalytics

enum SelectedView {
    case home
    case week
}

struct ContentView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var actionService: ActionService
    @Environment(\.scenePhase) var scenePhase
    
    @State private var selectedView: SelectedView = .home
    
    init() {
        Analytics.logEvent(AnalyticsEventAppOpen, parameters: [:])
    }
    
    func checkForAction() {
        guard let action = actionService.action else { return }
//        defer { actionService.action = nil }
        switch action {
        case .todayAction, .tomorrowAction:
            selectedView = .home
            // don't set the action to nil yet. The HomeView does that.
        case .weekAction:
            selectedView = .week
            actionService.action = nil
        }
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
        TabView(selection: $selectedView) {
            HomeView()
                .tabItem {
                    Label("Vandaag", systemImage: "calendar")
                }
                .tag(SelectedView.home)
            
            WeekView()
                .tabItem {
                    Label("Week", systemImage: "calendar.badge.clock")
                }
                .tag(SelectedView.week)
        }.onChange(of: scenePhase) { newValue in
            switch newValue {
            case .active:
                checkForAction()
            default: break;
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AuthManager())
            .environmentObject(ActionService())
    }
}
