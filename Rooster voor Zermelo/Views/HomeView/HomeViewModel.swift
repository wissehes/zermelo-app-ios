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
//    @Published var weekAppointments: [ZermeloLivescheduleAppointment] = []
    @Published var scheduleResult: Result<[ZermeloLivescheduleAppointment], AFError>?
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
        guard let scheduleResult = scheduleResult else { return [] }
        guard case .success(let data) = scheduleResult else { return [] }
        
        return data.filter { appointment in
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
        
    func load(animation: Bool = true) async {
        let week = API.getWeek(selectedDate)
        
        let result = await API.getLiveScheduleAsync(week: week)
        
        switch result {
        case .success(let data):
            if animation && shouldUpdateNotifications() {
                await NotificationsManager.scheduleNotifications(data)
            }
        default: break;
        }
        
        DispatchQueue.main.async {
            if animation {
                withAnimation {
                    self.scheduleResult = result
                    self.isLoading = false
                }
            } else {
                self.scheduleResult = result
                self.isLoading = false
            }
        }
    }
    
    func reload() async {
        await self.load(animation: false)
    }
    
    func dateChanged(_ newVal: Date) async {
        guard case .success(let appointments) = scheduleResult else { return await self.load(animation: true) }
        
        let filtered = appointments.filter { appointment in
            let date = Date(timeIntervalSince1970: TimeInterval(appointment.start))
            return Calendar.current.isDate(date, equalTo: newVal, toGranularity: .day)
        }
        
        if filtered.isEmpty {
            await self.load(animation: true)
        }
    }
    
    func shouldUpdateNotifications() -> Bool {
        let user = UserManager.getCurrent()
        let notifUser = NotificationsManager.getNotificationsUserId()
        
        guard let user = user else { return false }
        
        if notifUser.isEmpty {
            return true
        } else {
            return user.id == notifUser
        }
    }
}
