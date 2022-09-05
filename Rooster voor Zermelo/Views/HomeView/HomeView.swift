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
                    
                    self.todayAppointments = data.appointments.filter {
                        Calendar.current.isDateInToday(Date(timeIntervalSince1970: TimeInterval($0.start)))
                    }
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
    
    func itemView(_ item: ZermeloLivescheduleAppointment) -> some View {
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
                
                HStack {
                    if item.subjects.first != nil {
                        Text(item.subjects.joined(separator: ", "))
                            .font(.headline)
                    } else {
                        Text("Leeg")
                            .italic()
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    Text("-")
                    Text(item.teachers.joined(separator: ", "))
                    Text("-")
                    Text(item.locations.joined(separator: ", "))
                }
               
                timeView(appointment: item)
                    .font(.subheadline)
            }
        }
    }
    
    var todayView: some View {
        List(todayAppointments, id: \.start) { item in
            itemView(item)
        }
    }
}

            //struct HomeView_Previews: PreviewProvider {
            //    static var previews: some View {
            //        HomeView(token: ., me: .constant(nil))
            //    }
            //}
