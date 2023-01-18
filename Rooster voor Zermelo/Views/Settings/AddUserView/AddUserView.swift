//
//  AddUserView.swift
//  Rooster voor Zermelo
//
//  Created by Wisse Hes on 18/01/2023.
//

import SwiftUI
/**
 Meant to be shown in a .sheet
 */
struct AddUserView: View {
    var body: some View {
        NavigationStack {
            step1
                .navigationTitle("welcome.second.step")
                .multilineTextAlignment(.center)
        }
    }
    
    var step1: some View {
        VStack {
            Text("welcome.second.title")
                .padding()
            
            Image("ZermeloLogin1")
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 350)
            
            Spacer()
            
            NavigationLink("word.next") {
                step2
            }.buttonStyle(.borderedProminent)
                .padding()
            
            NavigationLink("Overslaan") {
                LoginView()
            }.buttonStyle(.bordered)
                .padding()
            
        }
    }
    
    var step2: some View {
        VStack {
            Text("welcome.third.title")
                .padding()
            
            Image("ZermeloLogin2")
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 250)
            
            Spacer()
            
            NavigationLink("word.next") {
                LoginView()
            }.buttonStyle(.borderedProminent)
                .padding()
        }.navigationTitle("welcome.third.step")
    }
}

struct LoginView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var isShowingScanner = false
    @State private var isLoading = false
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Text("welcome.fourth.title")
                .font(.headline)
                .padding()
            
            Image("ZermeloLogin3")
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 250)
                .border(.gray, width: 2)
            
            Text("welcome.fourth.subtitle").padding()
            
            Spacer()
            
            Button { isShowingScanner = true } label: {
                if isLoading {
                    ProgressView()
                } else {
                    Label("welcome.fourth.scanQRCode", systemImage: "qrcode.viewfinder")
                }
            }
                .buttonStyle(.borderedProminent)
        }.navigationTitle("welcome.fourth.step")
    }
}

struct AddUserView_Previews: PreviewProvider {
    static var previews: some View {
        AddUserView()
            .environmentObject(AuthManager())
    }
}
