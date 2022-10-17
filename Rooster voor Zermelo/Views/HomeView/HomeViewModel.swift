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
    @Published var todayAppointments: [ZermeloLivescheduleAppointment] = []
    @Published var isLoading = true
    
    @Published var days: [Day] = []
    
    @Published var selectedAppointment: ZermeloLivescheduleAppointment?
    
    @Published var selectedDate: Date = Date()
    var todaySelected: Bool {
        return Calendar.current.isDateInToday(selectedDate)
    }
    
    var me: ZermeloMeData?
    
    func load(me: ZermeloMeData) async {
        self.me = me
//        DispatchQueue.main.async {
//            withAnimation {
//                self.todayAppointments = []
//            }
//        }
        
        do {
            let foundAppointments = try await API.getScheduleForDay(me: me, date: selectedDate)
            DispatchQueue.main.async {
                withAnimation {
                    self.todayAppointments = foundAppointments
                }
            }
        } catch(let err) {
            print(err)
        }
    }
    
    func reload() async {
        guard let me = me else { return }
        await self.load(me: me)
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
