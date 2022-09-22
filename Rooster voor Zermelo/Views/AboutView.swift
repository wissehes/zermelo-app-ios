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
    
    var body: some View {
        List {
            Section("RoosterApp Voor Zermelo") {
                Text("RoosterApp voor Zermelo is gemaakt door [Wisse Hes](https://wissehes.nl)")
                
                Link(destination: URL(string: "https://github.com/wissehes/zermelo-app-ios")!) {
                    Label("GitHub (broncode)", systemImage: "chevron.left.forwardslash.chevron.right")
                }
                Link(destination: URL(string: "https://wissehes.nl/nl/projects/zermelo-app/")!) {
                    Label("Website", systemImage: "globe")
                }
                Link(destination: URL(string: "https://wissehes.nl/nl/contact/")!) {
                    Label("Contact", systemImage: "envelope")
                }
            }
            
            Section("Uitloggen") {
                Button(role: .destructive) { confirmationShowing = true } label: {
                    Label("Log uit", systemImage: "person.crop.circle.badge.xmark.fill")
                        .foregroundColor(.red)
                }
            }
            
            Section("Privacy") {
                Text("Deze app deelt jouw Zermelo gegevens niet met derden, er worden alleen gegevens uitgewisseld tussen jouw telefoon en Zermelo.")
            }
            
            Section("Disclaimer") {
                Text("Deze app is niet gemaakt door `Zermelo Software BV`. \nDeze app is niet ook verwant aan `Zermelo` of `Zermelo Software BV`.")
            }
        }.navigationTitle("Over deze app").confirmationDialog("Weet je het zeker?", isPresented: $confirmationShowing) {
            Button("Ja, uitloggen", role: .destructive) { authManager.signOut() }
            Button("Annuleren", role: .cancel) {}
        } message: {
            Text("Als je dit doet, moet je opnieuw inloggen via het Zermelo Portal")
        }
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AboutView()
        }
    }
}
