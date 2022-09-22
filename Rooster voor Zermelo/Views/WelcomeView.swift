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
            
            Text("Welkom bij Rooster voor Zermelo")
                .font(.title)
            Text("Om Rooster voor Zermelo te kunnen gebruiken, moeten we eerst inloggen.")
            
            Spacer()
            
            NavigationLink {
                SecondWelcomeScreen()
            } label: {
                
                NavigationLink(value: WelcomeScreen.second) {
                    Text("Laten we beginnen")
                }.buttonStyle(.borderedProminent)

            }

            
            Spacer()
        }
        .multilineTextAlignment(.center)
        .navigationTitle("Welkom")
        .padding()
    }
}

struct SecondWelcomeScreen: View {
    var body: some View {
        VStack {
//            Spacer()
            
            Text("Ga op je laptop naar jouw Zermelo Portal en klik op \"Portal\"").padding()
            
            Image("ZermeloLogin1")
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 350)
            
            Spacer()
            
            NavigationLink("Volgende", value: WelcomeScreen.third)
                .buttonStyle(.borderedProminent)
                .padding()
            
//            Spacer()
        }.multilineTextAlignment(.center)
            .navigationTitle("Stap 1")
    }
}

struct ThirdWelcomeScreen: View {
    var body: some View {
        VStack {
            Text("Druk dan linksbovenin op het icoontje onder het huisje.\nDruk vervolgens op \"`Koppel externe applicatie`\"").padding()
            
            Image("ZermeloLogin2")
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 250)
            
            Spacer()
            
            NavigationLink("Volgende", value: WelcomeScreen.fourth)
                .buttonStyle(.borderedProminent)
                .padding()
            
//            Spacer()
        }.navigationTitle("Stap 2")
    }
}

struct FourthWelcomeScreen: View {
    
    @State private var isShowingScanner = false
    @State private var isLoading = false
    
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
//            Spacer()
            
            Text("Als het goed is, ben je nu bij dit scherm.")
                .font(.headline)
                .padding()
            
            Image("ZermeloLogin3")
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 250)
                .border(.gray, width: 2)
            
            Text("Als dat zo is, kunnen we nu de QR-Code gaan scannen.").padding()
            
            Spacer()
            
            Button { isShowingScanner = true } label: {
                if isLoading {
                    ProgressView()
                } else {
                    Label("QR-code scannen", systemImage: "qrcode.viewfinder")
                }
            }
                .buttonStyle(.borderedProminent)
            
            NavigationLink(value: WelcomeScreen.manualCode) {
                Label("Code invoeren", systemImage: "keyboard")

            }.padding()
            
        }.navigationTitle("Stap 3")
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
    
    @EnvironmentObject var authManager: AuthManager

    @State private var school = ""
    @State private var code = ""
    
    @State private var isLoading = false
    @State private var loginErrorAlert = false
            
    var body: some View {
        Form {
            Text("Doet de QR code het niet? Of wil je geen QR code scannen? Hier kan je de gegevens handmatig invoeren.")
            
            HStack {
                Label("School", systemImage: "graduationcap")
                    .bold()
                TextField("School", text: $school)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .multilineTextAlignment(.trailing)
                Text(".zportal.nl")
                    .font(.subheadline)
            }
            
            HStack {
                Label("Code", systemImage: "key")
                    .bold()
                
                TextField("Code", text: $code)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.numberPad)
            }
            
            HStack {
                Button {
                    login()
                } label: {
                    Label("Inloggen", systemImage: "person.circle.fill")
                        .bold()
                }.disabled(isLoading || school.isEmpty || code.isEmpty)
                
                Spacer()
                
                if isLoading {
                    ProgressView()
                }
            }
            
            
        }.navigationTitle("Handmatig invoeren")
            .scrollDismissesKeyboard(.interactively)
            .alert("Er ging iets mis!", isPresented: $loginErrorAlert) {
                Button("Oké", role: .cancel) { }
            } message: {
                Text("Er ging iets mis tijdens het inloggen. Controleer of je alles goed hebt ingevuld en probeer het opnieuw.")
            }

    }
    
    func login() {
        isLoading = true

        authManager.handleLogin(school, code: code) { error in
            self.isLoading = false
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
