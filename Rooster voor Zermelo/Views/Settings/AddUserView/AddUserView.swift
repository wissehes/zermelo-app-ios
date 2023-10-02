//
//  AddUserView.swift
//  Rooster voor Zermelo
//
//  Created by Wisse Hes on 18/01/2023.
//

import SwiftUI
import CodeScanner

/**
 Meant to be shown in a .sheet
 */
struct AddUserView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            step1
                .navigationTitle("welcome.second.step")
                .multilineTextAlignment(.center)
        }
    }
    
    var step1: some View {
        VStack {
            Text("adduser.step1.title")
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
            
//            NavigationLink("Overslaan") {
//                LoginView()
//            }.buttonStyle(.bordered)
//                .padding()
            
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
                LoginView(dismiss: dismiss)
            }.buttonStyle(.borderedProminent)
                .padding()
        }.navigationTitle("welcome.third.step")
    }
}

struct LoginView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var isShowingScanner = false
    @State private var isLoading = false
    
    @State private var error: Error?
    @State private var errorShowing: Bool = false
    
    var dismiss: DismissAction
    
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
            
            NavigationLink {
                ManualLoginView(dismiss: dismiss)
            } label: {
                Label("welcome.fourth.enterCode", systemImage: "keyboard")
            }.buttonStyle(.bordered)
                .padding()
            
        }.navigationTitle("welcome.fourth.step")
            .sheet(isPresented: $isShowingScanner) {
                CodeScannerView(
                    codeTypes: [.qr],
                    showViewfinder: true,
                    simulatedData: "test",
                    completion: handleScan
                )
            }.alert("word.somethingWentWrong", isPresented: $errorShowing) {
                Button("word.ok") {}
            } message: {
                if let error = error {
                    Text(error.localizedDescription)
                } else {
                    Text("welcome.manual.alert.description" )
                }
            }

    }
    
    func handleScan(result: Result<ScanResult, ScanError>){
        isShowingScanner = false
        
        switch result {
        case .failure(let error):
            print(error.localizedDescription)
        case .success(let data):
            let stringData = data.string.data(using: .utf8)!
            guard let decoded = try? JSONDecoder().decode(ZermeloQRData.self, from: stringData) else { return; }
            
            API.getToken(decoded) { result in
                switch result {
                case .success(let token):
                    authManager.handleWelcomeScreenClosed(token)
                    dismiss()
                case .failure(let error):
                    print(error)
                    self.error = error
                    self.errorShowing = true
                }
            }
        }
    }
}

struct ManualLoginView: View {
    var dismiss: DismissAction
    
    @EnvironmentObject var authManager: AuthManager

    @State private var school = ""
    @State private var code = ""
    
    @FocusState private var focusCode: Bool
    
    @State private var isLoading = false
    @State private var error: Error?
    @State private var errorShowing: Bool = false
    
    var body: some View {
        Form {
            Text("welcome.manual.title")
            
            HStack {
                Label("welcome.manual.school", systemImage: "graduationcap")
                    .bold()
                TextField("welcome.manual.school", text: $school)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .multilineTextAlignment(.trailing)
                    .submitLabel(.next)
                    .onSubmit { focusCode = true }
                Text(verbatim: ".zportal.nl")
                    .font(.subheadline)
            }
            
            HStack {
                Label("welcome.manual.code", systemImage: "key")
                    .bold()
                
                TextField("welcome.manual.code", text: $code)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.numberPad)
                    .focused($focusCode)
            }
            
            HStack {
                Button {
                    login()
                } label: {
                    Label("welcome.manual.login", systemImage: "person.circle.fill")
                        .bold()
                }.disabled(isLoading || school.isEmpty || code.isEmpty)
                
                Spacer()
                
                if isLoading {
                    ProgressView()
                }
            }
            
            
        }.navigationTitle("welcome.manual.navTitle")
            .scrollDismissesKeyboard(.interactively)
            .alert("welcome.manual.alert.title", isPresented: $errorShowing) {
                Button("word.ok", role: .cancel) { }
            } message: {
                if let error = error {
                    Text(error.localizedDescription)
                } else {
                    Text("welcome.manual.alert.description" )
                }
            }
    }
    
    func login() {
        isLoading = true

        authManager.handleLogin(school: school, code: code, addUser: true) { error in
            self.isLoading = false
                dismiss()
            if error != nil {
                self.error = error
                self.errorShowing = true
            }
        }
    }
}

struct AddUserView_Previews: PreviewProvider {
    static var previews: some View {
        AddUserView()
            .environmentObject(AuthManager())
            .environment(\.locale, .init(identifier: "nl"))
    }
}
