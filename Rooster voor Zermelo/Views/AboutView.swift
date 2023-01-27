//
//  AboutView.swift
//  Rooster voor Zermelo
//
//  Created by Wisse Hes on 21/09/2022.
//

import SwiftUI

struct AboutView: View {
    @EnvironmentObject var authManager: AuthManager
    
    @State var confirmationShowing = false
    
    var version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
    var build = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String ?? ""
    
    var body: some View {
        List {
            Section("RoosterApp Voor Zermelo") {
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
            }
            
            Section("about.logout") {
                Button(role: .destructive) { confirmationShowing = true } label: {
                    Label("about.logout", systemImage: "person.crop.circle.badge.xmark.fill")
                        .foregroundColor(.red)
                }
            }
            
            Section("about.privacy") {
                Text("about.privacy.text")
            }
            
            Section("about.disclaimer") {
                Text("about.disclaimer.text")
            }
            
            Section("Versie") {
                Text("about.version \(version) \(build)")
                    .font(.subheadline)
            }
        }.navigationTitle("about.about")
            .confirmationDialog("about.logout.confirm.title", isPresented: $confirmationShowing) {
            Button("about.logout.confirm.confirm", role: .destructive) { authManager.signOut() }
            Button("word.cancel", role: .cancel) {}
        } message: {
            Text("about.logout.confirm.subtitle")
        }
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
