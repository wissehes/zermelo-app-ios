//
//  SettingsView.swift
//  Rooster voor Zermelo
//
//  Created by Wisse Hes on 15/01/2023.
//

import SwiftUI
import UserNotifications
import FirebaseAnalytics

extension UNAuthorizationStatus {
    var text: LocalizedStringKey {
        switch self {
        case .notDetermined:
            return "settings.notifications.status.loading"
        case .denied:
            return "settings.notifications.status.permissionDenied"
        case .authorized:
            return "settings.notifications.status.permissionGranten"
        default: return "Unknown."
        }
    }
}

struct SettingsView: View {
    
    @EnvironmentObject var authManager: AuthManager
    
    @AppStorage("showNotifications") var showNotifications: Bool = false
    
    @StateObject var viewModel = SettingsViewModel()
    
    @State var notifError: Error? = nil
    @State var notifErrorShown: Bool = false
    @State var permissionState: UNAuthorizationStatus = .notDetermined
    
    @State var logoutConfirmationShowing: Bool = false
    @State var addUserShowing: Bool = false
    
    var body: some View {
        List {
            
            Section("settings.account.current") {
                if let user = viewModel.user {
                    UserListItem(user: user)
                }
            }.onAppear {
                viewModel.load()
            }
            
            Section("settings.users") {
                
                NavigationLink {
                    Userlist()
                } label: {
                    Label("settings.account.switch", systemImage: "person.3.fill")
                        .symbolRenderingMode(.multicolor)
                }
                
                Button {
                    self.addUserShowing = true
                } label: {
                    Label("settings.users.add", systemImage: "person.crop.circle.badge.plus")
                        .symbolRenderingMode(.multicolor)
                }
                
                Button(role: .destructive) {
                    self.logoutConfirmationShowing = true
                } label: {
                    Label("settings.users.logout", systemImage: "person.crop.circle.badge.xmark")
                        .symbolRenderingMode(.multicolor)
                }
            }
            
            Section {
                Button("settings.openSettings") {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                }
            } header: {
                Text("settings.language")
            } footer: {
                Text("settings.language.change")
            }
            
            Section("settings.notifications") {
                Toggle("settings.notifications", isOn: $showNotifications)
                    .disabled(permissionState == .denied)
                
                if permissionState == .denied || permissionState == .ephemeral || permissionState == .provisional {
                    Text(permissionState.text)
                        .font(.subheadline)
                }
                if permissionState == .authorized && viewModel.users.count > 1 {
                    NotificationSettings()
                    
                }
            }
        }.navigationTitle("settings.settings")
            .alert("word.error", isPresented: $notifErrorShown) {
                Button("word.ok") {}
            } message: {
                Text(notifError?.localizedDescription ?? "")
            }.onAppear {
                checkNotificationPermissions()
                Analytics.logEvent(AnalyticsEventScreenView,
                                   parameters: [AnalyticsParameterScreenName: "Settings"])
            }.onChange(of: showNotifications) { _ in
                onChangeNotifications()
            }.confirmationDialog("about.logout.confirm.title", isPresented: $logoutConfirmationShowing) {
                Button("about.logout.confirm.confirm", role: .destructive) { authManager.signOut() }
                Button("word.cancel", role: .cancel) {}
            } message: {
                Text("about.logout.confirm.subtitle")
            }.sheet(isPresented: $addUserShowing) {
                AddUserView()
            }
        
    }
    
    func onChangeNotifications() {
        Analytics.setUserProperty(showNotifications ? "ON" : "OFF", forName: "Show notifications")
        
        if showNotifications {
            NotificationsManager.requestPermission { result in
                switch result {
                case .success(let result):
                    withAnimation {
                        self.permissionState = result ? .authorized : .denied
                        self.showNotifications = result
                    }
                    
                case .failure(let failure):
                    self.notifError = failure
                    self.notifErrorShown = true
                    self.permissionState = .denied
                    self.showNotifications = false
                }
            }
        } else {
            // if notifications are disabled, remove all pending ones
            NotificationsManager.removeAllNotifications()
        }
    }
    
    func checkNotificationPermissions() {
        NotificationsManager.getPermissionStatus { setting in
            withAnimation {
                self.permissionState = setting.authorizationStatus
                if self.showNotifications && self.permissionState != .authorized {
                    self.showNotifications = false
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SettingsView()
                .environmentObject(AuthManager())
        }
    }
}
