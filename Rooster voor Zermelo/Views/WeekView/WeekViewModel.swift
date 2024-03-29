//
//  WeekViewModel.swift
//  Rooster voor Zermelo
//
//  Created by Wisse Hes on 06/09/2022.
//

import Foundation
import SwiftUI
import Alamofire

struct Day: Hashable {
    static func == (lhs: Day, rhs: Day) -> Bool {
        return Calendar.current.isDate(lhs.date, inSameDayAs: rhs.date)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(date.ISO8601Format())
    }
    
    let date: Date
    var appointments: [ZermeloLivescheduleAppointment]
    
    var shortDay: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EE"
        return formatter.string(from: date)
    }
}

final class WeekViewModel: ObservableObject {
    @Published var days: [Day] = []
    
    @Published var appointmentDetailsShown = false
    @Published var selectedAppointment: ZermeloLivescheduleAppointment?
    
    @Published var selectedDate = Date()
    @Published var error: AFError?
    
    func load(date: Date?) async {
        let week = API.getWeek(date ?? selectedDate)
        
        
        let result = await API.getLiveScheduleAsync(week: week)
        
        switch result {
        case .success(let appointments):
            self.mapAppointments(appointments)
        case .failure(let error):
            DispatchQueue.main.async {
                self.error = error
            }
        }
    }
    
    private func mapAppointments(_ appointments: [ZermeloLivescheduleAppointment]) {
        DispatchQueue.main.async {
            self.days = []
            for appointment in appointments {
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
        }
    }
}
