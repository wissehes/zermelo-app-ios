//
//  AboutView.swift
//  Rooster voor Zermelo
//
//  Created by Wisse Hes on 21/09/2022.
//

import SwiftUI

struct AboutView: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        List {
            
            Section("Rooster voor Zermelo") {
                Text("`Rooster voor Zermelo` is een iOS app gemaakt door [Wisse Hes](https://wissehes.nl). Deze app is niet verwant aan `Zermelo` of `Zermelo Software BV`.")
            }
            
            Section("Uitloggen") {
                Button("Log uit") { authManager.signOut() }
            }
        }.navigationTitle("Over deze app")
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
