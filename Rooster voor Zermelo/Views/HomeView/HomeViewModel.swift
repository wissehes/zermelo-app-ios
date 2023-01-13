//
//  HomeViewModel.swift
//  Rooster voor Zermelo
//
//  Created by Wisse Hes on 05/09/2022.
//

import Foundation
import Alamofire
import SwiftUI

final class HomeViewModel: ObservableObject {
//    @Published var todayAppointments: [ZermeloLivescheduleAppointment] = []
    @Published var weekAppointments: [ZermeloLivescheduleAppointment] = []
    @Published var isLoading = true
    
    @Published var selectedAppointment: ZermeloLivescheduleAppointment?
    
    @Published var selectedDate: Date = Date()
    var todaySelected: Bool {
        return Calendar.current.isDateInToday(selectedDate)
    }
    var tomorrowSelected: Bool {
        return Calendar.current.isDateInTomorrow(selectedDate)
    }
    var todayAppointments: [ZermeloLivescheduleAppointment] {
        return weekAppointments.filter { appointment in
            let date = Date(timeIntervalSince1970: TimeInterval(appointment.start))
            return Calendar.current.isDate(date, equalTo: selectedDate, toGranularity: .day)
        }
    }
    
    var formatter: DateFormatter
    
    init() {
        self.formatter = DateFormatter()
        self.formatter.dateFormat = "EEEE d MMMM"
    }
    
    var navTitle: LocalizedStringKey {
        let formatted = formatter.string(from: self.selectedDate)
        if self.todaySelected {
            return "word.today.parentheses \(formatted)"
        } else if self.tomorrowSelected {
            return "word.tomorrow.parentheses \(formatted)"
        } else {
            return "\(formatted)"
        }
    }
    
    var me: ZermeloMeData?
    
    func load(me: ZermeloMeData, animation: Bool = true) async {
        self.me = me
        let week = API.getWeek(selectedDate)
        do {
            let foundAppointments = try await API.getLiveScheduleAsync(me: me, week: week)
            
            DispatchQueue.main.async {
                if animation {
                    withAnimation {
                        self.weekAppointments = foundAppointments
                        self.isLoading = false
                    }
                } else {
                    self.weekAppointments = foundAppointments
                    self.isLoading = false
                }
            }
        } catch(let err) {
            print(err)
        }
    }
    
    func reload() async {
        guard let me = me else { return }
        await self.load(me: me, animation: false)
    }
    
    func dateChanged(_ newVal: Date) async {
        let filtered = weekAppointments.filter { appointment in
            let date = Date(timeIntervalSince1970: TimeInterval(appointment.start))
            return Calendar.current.isDate(date, equalTo: newVal, toGranularity: .day)
        }
        
        if filtered.isEmpty {
            guard let me = me else { return }
            await self.load(me: me, animation: true)
        }
    }
    
    //    func load(me: ZermeloMeData) {
    //        self.isLoading = true
    //        print("loading...")
    //
    //        API.getLiveSchedule(me: me) { result in
    //            self.isLoading = false
    //            switch result {
    //            case .success(let data):
    //
    //                for appointment in data {
    //                    self.days = []
    //                    let date = Date(timeIntervalSince1970: TimeInterval(appointment.start))
    //
    //                    let foundRow = self.days.firstIndex { day in
    //                        Calendar.current.isDate(day.date, equalTo: date, toGranularity: .day)
    //                    }
    //
    //                    if let foundRow = foundRow {
    //                        self.days[foundRow].appointments.append(appointment)
    //                    } else {
    //                        self.days.append(Day( date: date, appointments: [appointment] ))
    //                    }
    //                }
    //
    //                self.todayAppointments = data.filter {
    //                    Calendar.current.isDateInToday(Date(timeIntervalSince1970: TimeInterval($0.start)))
    //                }
    //            case .failure(let failure):
    //                print(failure)
    //            }
    //        }
    //    }
}
