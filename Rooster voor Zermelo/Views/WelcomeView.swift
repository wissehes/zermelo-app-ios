//
//  WelcomeView.swift
//  Rooster voor Zermelo
//
//  Created by Wisse Hes on 03/09/2022.
//

import SwiftUI
import CodeScanner
import Alamofire

fileprivate enum WelcomeScreen: Hashable {
    case first
    case second
    case third
    case fourth
    
    case manualCode
}

struct WelcomeView: View {
    @State private var selectedView = 1
    @State private var isShowingScanner = false
    @State private var isLoading = false
    
    
    var body: some View {
        NavigationStack {
            FirstWelcomeScreen()
//            ManualCodeScreen()
                .navigationDestination(for: WelcomeScreen.self) { i in
                    switch i {
                    case .first:
                        FirstWelcomeScreen()
                    case .second:
                        SecondWelcomeScreen()
                    case .third:
                        ThirdWelcomeScreen()
                    case .fourth:
                        FourthWelcomeScreen()
                    case .manualCode:
                        ManualCodeScreen()
                    }
                }
        }
    }
}

struct FirstWelcomeScreen: View {
    var body: some View {
        VStack {
            Spacer()
            
            Text("welcome.first.title")
                .font(.title)
            Text("welcome.first.subtitle")
            
            Spacer()
            
            NavigationLink {
                SecondWelcomeScreen()
            } label: {
                
                NavigationLink(value: WelcomeScreen.second) {
                    Text("welcome.first.begin")
                }.buttonStyle(.borderedProminent)

            }

            
            Spacer()
        }
        .multilineTextAlignment(.center)
        .navigationTitle("word.welcome")
        .padding()
    }
}

struct SecondWelcomeScreen: View {
    var body: some View {
        VStack {
//            Spacer()
            
            Text("welcome.second.title").padding()
            
            Image("ZermeloLogin1")
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 350)
            
            Spacer()
            
            NavigationLink("word.next", value: WelcomeScreen.third)
                .buttonStyle(.borderedProminent)
                .padding()
            
//            Spacer()
        }.multilineTextAlignment(.center)
            .navigationTitle("welcome.second.step")
    }
}

struct ThirdWelcomeScreen: View {
    var body: some View {
        VStack {
            Text("welcome.third.title").padding()
            
            Image("ZermeloLogin2")
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 250)
            
            Spacer()
            
            NavigationLink("word.next", value: WelcomeScreen.fourth)
                .buttonStyle(.borderedProminent)
                .padding()
            
//            Spacer()
        }.navigationTitle("welcome.third.step")
    }
}

struct FourthWelcomeScreen: View {
    
    @State private var isShowingScanner = false
    @State private var isLoading = false
    
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
//            Spacer()
            
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
            
            NavigationLink(value: WelcomeScreen.manualCode) {
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
            requestAndSaveToken(data: decoded)
        }
    }
    
    func requestAndSaveToken(data: ZermeloQRData) {
        isLoading = true

        let params: Parameters = [
            "grant_type": "authorization_code",
            "code": data.code
        ]
        AF.request("https://\(data.institution).zportal.nl/api/v3/oauth/token", method: .post, parameters: params)
            .validate()
            .responseDecodable(of: ZermeloTokenRequest.self){ response in
//                isLoading = false

                switch response.result {
                case .failure(let err):
                    print("AF Error")
                    print(err)
                case .success(let tokenInfo):
                    let tokenData = SavedToken.init(qrData: data, tokenInfo: tokenInfo)
                    TokenSaver.save(tokendata: tokenData)
                    authManager.handleWelcomeScreenClosed(tokenData)
                }
            }
    }
}

struct ManualCodeScreen: View {
    
    var addUser: Bool = false
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var authManager: AuthManager

    @State private var school = ""
    @State private var code = ""
    
    @FocusState private var focusCode: Bool
    
    @State private var isLoading = false
    @State private var loginErrorAlert = false
            
    var body: some View {
        Form {
            Text("welcome.manual.title")
            
            HStack {
                Label("welcome.manual.school", systemImage: "graduationcap")
                    .bold()
                TextField("welcome.manual.school", text: $school)
                    .lineLimit(1)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .multilineTextAlignment(.trailing)
                    .submitLabel(.next)
                    .onSubmit { focusCode = true }
                Text(".zportal.nl")
                    .font(.subheadline)
            }
            
            HStack {
                Label("welcome.manual.code", systemImage: "key")
                    .bold()
                
                TextField("welcome.manual.code", text: $code)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.numberPad)
//                    .submitLabel(.)
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
            .alert("welcome.manual.alert.title", isPresented: $loginErrorAlert) {
                Button("word.ok", role: .cancel) { }
            } message: {
                Text("welcome.manual.alert.description")
            }

    }
    
    func login() {
        isLoading = true

        authManager.handleLogin(school: school, code: code, addUser: addUser) { error in
            self.isLoading = false
            if addUser {
                dismiss()
            }
            if error != nil {
                self.loginErrorAlert = true
            }
        }
    }
}


struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
