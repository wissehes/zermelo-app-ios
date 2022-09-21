//
//  WelcomeView.swift
//  Rooster voor Zermelo
//
//  Created by Wisse Hes on 03/09/2022.
//

import SwiftUI
import CodeScanner
import Alamofire

struct WelcomeView: View {
    @State private var selectedView = 1
    @State private var isShowingScanner = false
    @State private var isLoading = false
    
    var handleClose: (_ token: SavedToken) -> ()
    
    var body: some View {
        NavigationView {
            TabView(selection: $selectedView) {
                firstScreen
                    .tag(1)
                
                secondScreen
                    .tag(2)
                
                thirdScreen
                    .tag(3)
                
                fourthScreen
                    .tag(4)
            }.navigationTitle("Welkom")
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                .sheet(isPresented: $isShowingScanner) {
                    CodeScannerView(
                        codeTypes: [.qr],
                        showViewfinder: true,
                        simulatedData: "test",
                        completion: handleScan
                    )
                }
        }
    }
    
    var firstScreen: some View {
        VStack {
            Spacer()
            
            Text("Welkom bij Rooster voor Zermelo")
            Text("Om Rooster voor Zermelo te kunnen gebruiken, moeten we eerst inloggen.")
            
            Spacer()
            
            Button("Laten we beginnen") {
                withAnimation {
                    selectedView = 2
                }
            }.buttonStyle(.borderedProminent)
            
            Spacer()
        }.padding()
    }
    
    var secondScreen: some View {
        VStack {
            Text("Stap 1")
                .font(.largeTitle)
                .fontWeight(.bold)
            
//            Spacer()
            
            Text("Ga op je laptop naar jouw Zermelo Portal en klik op \"Portal\"").padding()
            
            Image("ZermeloLogin1")
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 350)
            
            Spacer()
            
            Button("Volgende") {
                withAnimation {
                    selectedView = 3
                }
            }.buttonStyle(.borderedProminent)
            
            Spacer()
        }.multilineTextAlignment(.center)
    }
    
    var thirdScreen: some View {
        VStack {
            Text("Stap 2")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Druk dan linksbovenin op het icoontje onder het huisje. Druk vervolgens op \"Koppel externe applicatie\"").padding()
            
            Image("ZermeloLogin2")
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 250)
            
            Spacer()
            
            Button("Volgende") {
                withAnimation {
                    selectedView = 4
                }
            }.buttonStyle(.borderedProminent)
            
            Spacer()
        }
    }
    
    var fourthScreen: some View {
        VStack {
            Text("Stap 3")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Spacer()
            
            Text("Als het goed is, ben je nu bij dit scherm.").padding()
            
            Image("ZermeloLogin3")
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 250)
            
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
            
            Spacer()
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
                    
                    self.handleClose(tokenData)
                }
            }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView() { token in
            print(token)
        }
    }
}
