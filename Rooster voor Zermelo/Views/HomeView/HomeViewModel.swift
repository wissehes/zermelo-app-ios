//
//  HomeViewModel.swift
//  Rooster voor Zermelo
//
//  Created by Wisse Hes on 05/09/2022.
//

import Foundation
import Alamofire
import SwiftUI
import FirebaseAnalytics

final class HomeViewModel: ObservableObject {
    @Published var scheduleResult: Result<[ZermeloLivescheduleAppointment], AFError>?
    @Published var isLoading = true
    
    @Published var selectedAppointment: ZermeloLivescheduleAppointment?
    
    @Published var selectedDate: Date = Date()
    
    @Published var users: [User] = []
    @Published var currentUser: User?
    
    var formatter: DateFormatter

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
    
    init() {
        self.formatter = DateFormatter()
        self.formatter.dateFormat = "EEEE d MMMM"
    }
    
    var navTitle: String {
        let formatted = formatter.string(from: self.selectedDate)
        
        if self.todaySelected {
            return String(localized: "word.today.parentheses \(formatted)")
        } else if self.tomorrowSelected {
            return String(localized: "word.tomorrow.parentheses \(formatted)")
        } else {
            return formatted
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
    
    func reloadUsers() {
        self.users = UserManager.getAll()
        if let current = UserManager.getCurrent() {
            self.currentUser = current
        }
    }
    
    func updateUsers() {
        guard let current = currentUser else { return }
        UserManager.setCurrent(id: current.id)
    }
    
    func dateChanged(_ newVal: Date) async {
        guard case .success(let appointments) = scheduleResult else { return await self.load(animation: true) }
        
        let filtered = appointments.filter { appointment in
            let date = Date(timeIntervalSince1970: TimeInterval(appointment.start))
            return Calendar.current.isDate(date, equalTo: newVal, toGranularity: .day)
        }
        
        if filtered.isEmpty {
//            DispatchQueue.main.async {
//                self.isLoading = true
//            }
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
    
    func hanldeGestureEnd(_ value: DragGesture.Value) {
        let horizontalChange = value.startLocation.x - value.predictedEndLocation.x
        let verticalChange = value.startLocation.y -  value.predictedEndLocation.y
        
//        print("Hor: ", horizontalChange)
//        print("Ver: ", verticalChange)
        
        // Make sure the horizontal change is bigger than the vertical change
        guard makeItPositive(horizontalChange) > makeItPositive(verticalChange) else { return }
        
        // Swipe from right-to-left
        if horizontalChange > 50 {
            let newDate = Calendar.current.date(byAdding: .day, value: 1, to: self.selectedDate)
            self.selectedDate = newDate!
        // Swipe from left-to-right
        } else if horizontalChange < -50 {
            let newDate = Calendar.current.date(byAdding: .day, value: -1, to: self.selectedDate)
            self.selectedDate = newDate!
        }
    }
    
    private func makeItPositive(_ num: Double) -> Double {
        if num > 0 {
            return num
        } else {
            return -num
        }
    }
}
