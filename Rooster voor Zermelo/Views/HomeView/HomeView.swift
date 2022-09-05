//
//  HomeView.swift
//  Rooster voor Zermelo
//
//  Created by Wisse Hes on 04/09/2022.
//

import SwiftUI
import Alamofire

struct HomeView: View {
    var token: SavedToken
    
    // Only use `didSet` on `me` because it is the last
    // thing set, after the token.
    var me: ZermeloMeData {
        didSet {
            load()
        }
    }
    
    var signOut: () -> ()
    
    @State private var todayAppointments: [ZermeloLivescheduleAppointment] = []
    @State private var isLoading = true
    
    func load() {
        //        guard let token = token else { return print("no token") }
        //        guard let me = me else { return print("no me") }
        
        self.isLoading = true
        print("loading...")
        
        let params: Parameters = [
            "student": me.code,
            "week": 202236
        ]
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token.access_token)"
        ]
        
        AF.request("https://\(token.portal).zportal.nl/api/v3/liveschedule", parameters: params, headers: headers)
            .validate()
            .responseDecodable(of: GetZermeloLiveschedule.self) { response in
                self.isLoading = false
                switch response.result {
                case .success(let _data):
                    guard let data = _data.response.data.first else { return }
                    
                    self.todayAppointments = data.appointments
                case .failure(let err):
                    print(err)
                }
            }
    }
    
    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView()
                } else {
                    todayView
                }
            }.navigationTitle("Home")
                .toolbar {
                    ToolbarItem(placement: .destructiveAction) {
                        Button("Uitloggen") {
                            signOut()
                        }
                    }
                }
        }.onAppear { load() }
        
    }
    
    func timeView(appointment: ZermeloLivescheduleAppointment) -> some View {
        let start = Date(timeIntervalSince1970: TimeInterval(appointment.start))
        let endDate = Date(timeIntervalSince1970: TimeInterval(appointment.end))
                                            
        return Text("\(start, style: .time) - \(endDate, style: .time)")
    }
    
    var todayView: some View {
        List(todayAppointments, id: \.start) { item in
            HStack {
                Text(item.startTimeSlotName)
                    .fontWeight(.bold)
                    .frame(width: 25, height: 25, alignment: .center)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.accentColor, lineWidth: 5)
                            .padding(5)
                    )
                
                VStack(alignment: .leading) {
                    
                    if item.subjects.first != nil {
                        Text(item.subjects.joined(separator: ", "))
                            .font(.headline)
                    } else {
                        Text("Leeg")
                            .italic()
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                   
                    timeView(appointment: item)
                        .font(.subheadline)
                }
            }
        }
    }
}

            //struct HomeView_Previews: PreviewProvider {
            //    static var previews: some View {
            //        HomeView(token: ., me: .constant(nil))
            //    }
            //}
