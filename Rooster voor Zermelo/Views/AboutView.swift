//
//  AboutView.swift
//  Rooster voor Zermelo
//
//  Created by Wisse Hes on 21/09/2022.
//

import SwiftUI

struct AboutView: View {
//    @EnvironmentObject var authManager: AuthManager
    
    @State var confirmationShowing = false
    
    var version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
    var build = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String ?? ""
    
    var body: some View {
        List {
            Section {
                Text("about.madeBy")
                
                Link(destination: URL(string: "https://github.com/wissehes/zermelo-app-ios")!) {
                    Label("about.github", systemImage: "chevron.left.forwardslash.chevron.right")
                }
                Link(destination: URL(string: "https://wissehes.nl/nl/projects/zermelo-app/")!) {
                    Label("about.website", systemImage: "globe")
                }
                Link(destination: URL(string: "https://wissehes.nl/nl/contact/")!) {
                    Label("about.contact", systemImage: "envelope")
                }
            } header: {
                Label("RoosterApp Voor Zermelo", systemImage: "app.badge")
            }
            
            Section {
                HStack(alignment: .center) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.yellow)
                        .frame(height: 30)
                        .padding([.trailing])
                    Text("about.maintenance.title")
                        .font(.headline)
                }
                
                Text("about.maintenance.description")
            } header: {
                Label("about.maintenance.header", systemImage: "exclamationmark.triangle.fill")
            }

            
            Section {
                Text("about.privacy.text")
                
                Link(destination: URL(string: "https://firebase.google.com/support/privacy")!) {
                    Label("about.privacy.google", systemImage: "globe")
                }
                Link(destination: URL(string: "https://sentry.io/privacy/")!) {
                    Label("about.privacy.sentry", systemImage: "globe")
                }
            } header: {
                Label("about.privacy", systemImage: "lock")
            }
            
            Section("about.disclaimer") {
                Text("about.disclaimer.text")
            }
            
            Section("Versie") {
                Text("about.version \(version) \(build)")
                    .font(.subheadline)
            }
        }.navigationTitle("about.about")
        .analyticsScreen(name: "About")
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AboutView()
        }
    }
}
