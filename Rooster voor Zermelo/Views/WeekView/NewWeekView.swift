//
//  NewWeekView.swift
//  Rooster voor Zermelo
//
//  Created by Wisse Hes on 17/10/2022.
//

import SwiftUI

struct NewWeekView: View {
    
    let days: [String] = ["Ma", "Di", "Wo", "Do", "Vr"]
    let a = ["GS", "DUTL", "NETL", "WA"]
    let l = ["6s", "10r", "11a", "at1-bov", "18l"]
    
    @StateObject var viewModel = WeekViewModel()
    @EnvironmentObject var authManager: AuthManager

    
    var body: some View {
        GeometryReader { geo in
            HStack(alignment: .top) {
                Spacer()
                ForEach(viewModel.days, id: \.date.timeIntervalSince1970) { day in
                    VStack(alignment: .center) {
                        Text(day.shortDay)
                            .fontWeight(.heavy)
                            .foregroundColor(.secondary)
                        //                        .multilineTextAlignment(.leading)
                        
                        ForEach(day.appointments, id: \.self) { app in
                            appointment(geo, app: app)
                        }
                        
                        Spacer()
                    }
                }
                Spacer()
            }
        }.navigationTitle("Week")
            .task {
                await viewModel.load(date: nil)
            }
    }
    
    func appointment(_ geo: GeometryProxy, app: ZermeloLivescheduleAppointment) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(app.subjects.joined(separator: ","))
                    .fontWeight(.bold)
                    .multilineTextAlignment(.leading)
                
                Text(app.locations.joined(separator: ","))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                
            }.padding(5)
            Spacer()
        }.frame(width: (geo.size.width - 50) / 5, height: 60)
            .overlay(
                RoundedRectangle(cornerRadius: 2.5)
                    .stroke(lineWidth: 1)
            )
        
    }
}

struct NewWeekView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            NewWeekView()
        }.environmentObject(AuthManager())
    }
}
