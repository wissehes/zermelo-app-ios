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
    
//    @StateObject var viewModel = WeekViewModel()
    @StateObject var vm = NewWeekViewModel()
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        HStack {
            ForEach(vm.weekDays, id: \.day.rawValue) { day in
                Text(day.day.rawValue)
            }
        }
    }
}

final class NewWeekViewModel: ObservableObject {
    @Published var weeks: [Week] = []
    @Published var weekDays: [WeekDayData] = []
    @Published var currentWeek: Date = getCurrentWeek() // First day of the week
    @Published var currentDate: Date = Date()
    
    @Published var earliestTime: Date?
    @Published var latestTime: Date?
    
//    init() {
//        self.weekDays = []
//        self.currentWeek = Self.getCurrentWeek()
////        Task {
////            await self.fetch()
////        }
//    }
    
    func fetch() async {
        print("Week:", self.currentWeek.formatted(.dateTime))
        
        let data = await API.getLiveScheduleAsync(week: API.getWeek(self.currentWeek))
        
        switch data {
        case .success(let appointments):
            let week = self.convertToWeek(appointments)
//            print(week)
            DispatchQueue.main.async {
                self.weekDays = week
            }
        case .failure(let error):
            print(error)
        }
    }
    
    func convertToWeek(_ appointments: [ZermeloLivescheduleAppointment]) -> [WeekDayData] {
        
        var week: [WeekDayData] = []
        
        for appointment in appointments {
            let start = Date(timeIntervalSince1970: TimeInterval(appointment.start))
            let end = Date(timeIntervalSince1970: TimeInterval(appointment.end))
            if let foundIndex = week.firstIndex(where: {
                Calendar.current.isDate(start, inSameDayAs: $0.day.date(date: currentWeek))
            }) {
                week[foundIndex].appointments.append(appointment)
            } else if let day = WeekDay.allCases.first(where: {
                Calendar.current.isDate(start, inSameDayAs: $0.date(date: currentWeek))
            }) {
                week.append(WeekDayData(day: day, appointments: [appointment]))
            }
        }
        
        for day in WeekDay.allCases {
            if week.first(where: { $0.day == day }) == nil {
                week.append(WeekDayData(day: day, appointments: []))
            }
        }
        
        return week
    }
    
    static func getCurrentWeek() -> Date {
        let today = Date()
        let monday = today.startOfWeek()
        return monday
    }
}

struct WeekDayData {
    let day: WeekDay
    var appointments: [ZermeloLivescheduleAppointment]
}

struct Week {
    let weeks: [WeekDayData]
}

enum WeekDay: String, CaseIterable {
    case monday = "Ma"
    case tuesday = "Di"
    case wednesday = "Wo"
    case thursday = "Do"
    case friday = "Vr"
}
extension WeekDay {
    func date(date: Date) -> Date {
        switch self {
        case .monday:
            return Calendar.current.date(byAdding: .day, value: 0, to: date)!
        case .tuesday:
            return Calendar.current.date(byAdding: .day, value: 1, to: date)!
        case .wednesday:
            return Calendar.current.date(byAdding: .day, value: 2, to: date)!
        case .thursday:
            return Calendar.current.date(byAdding: .day, value: 3, to: date)!
        case .friday:
            return Calendar.current.date(byAdding: .day, value: 4, to: date)!
        }
    }

}

struct NewWeekView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            NewWeekView()
        }.environmentObject(AuthManager())
    }
}

extension Calendar {
    static let gregorian = Calendar(identifier: .gregorian)
}

extension Date {
    func startOfWeek(using calendar: Calendar = .gregorian) -> Date {
        let s = calendar.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: self).date!
        return Calendar.gregorian.date(byAdding: .day, value: 1, to: s)!
    }
}
