//
//  HomeViewModel.swift
//  Rooster voor Zermelo
//
//  Created by Wisse Hes on 05/09/2022.
//

import Foundation
import Alamofire

struct Day {
    let date: Date
    var appointments: [ZermeloLivescheduleAppointment]
}

final class HomeViewModel: ObservableObject {
    @Published var todayAppointments: [ZermeloLivescheduleAppointment] = []
    @Published var isLoading = true
    
    @Published var days: [Day] = []
    
    @Published var appointmentDetailsShown = false
    @Published var selectedAppointment: ZermeloLivescheduleAppointment?
    
    func showItemDetails(_ item: ZermeloLivescheduleAppointment) {
        self.selectedAppointment = item
        appointmentDetailsShown = true
    }
    
    func load(me: ZermeloMeData) {
        self.isLoading = true
        print("loading...")
        
        API.getLiveSchedule(me: me) { result in
            self.isLoading = false
            switch result {
            case .success(let data):
                
                for appointment in data {
                    let date = Date(timeIntervalSince1970: TimeInterval(appointment.start))
                    
                    let foundRow = self.days.firstIndex { day in
                        Calendar.current.isDate(day.date, equalTo: date, toGranularity: .day)
                    }
                    
                    if let foundRow = foundRow {
                        self.days[foundRow].appointments.append(appointment)
                    } else {
                        self.days.append(Day( date: date, appointments: [appointment] ))
                    }
                }
                
                print(self.days.map { $0.appointments.map { $0.subjects } })
                
                self.todayAppointments = data.filter {
                    Calendar.current.isDateInToday(Date(timeIntervalSince1970: TimeInterval($0.start)))
                }
            case .failure(let failure):
                print(failure)
            }
        }
    }
}
