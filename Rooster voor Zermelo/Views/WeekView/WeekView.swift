//
//  WeekView.swift
//  Rooster voor Zermelo
//
//  Created by Wisse Hes on 06/09/2022.
//

import SwiftUI
import FirebaseAnalytics

struct WeekView: View {
    @EnvironmentObject var authManager: AuthManager
    
    @StateObject var viewModel = WeekViewModel()
    let tomorrow = Date().addingTimeInterval(24 * 60 * 60)
    
    func scrollToToday(_ proxy: ScrollViewProxy) {
        let todayDate = viewModel.days.first(where: { Calendar.current.isDateInToday($0.date) })
        if let todayDate = todayDate {
            withAnimation {
                proxy.scrollTo(todayDate.date.ISO8601Format(), anchor: .center)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                List {
                    ForEach(viewModel.days, id: \.date.timeIntervalSince1970) { day in
                        Section {
                            DayView(appointments: day.appointments)
                        } header: {
                            if Calendar.current.isDateInToday(day.date) {
                                Text("word.today.parentheses \(day.date, style: .date)")
                            } else if Calendar.current.isDate(tomorrow, equalTo: day.date, toGranularity: .day) {
                                Text("word.tomorrow.parentheses \(day.date, style: .date)")
                            } else {
                                Text(formatDate(day.date))
                            }
                        }.textCase(nil)
                            .headerProminence(.increased)
                            .id(day.date.ISO8601Format())
                    }
                }.navigationTitle("word.week")
                    .toolbar {
                        ToolbarItem(placement: .primaryAction) {
                            Button("word.today") { scrollToToday(proxy) }
                        }
                        ToolbarItem(placement:.bottomBar) {
                            DatePicker("word.week", selection: $viewModel.selectedDate, displayedComponents: .date)
                        }
                    }
                    .listStyle(.sidebar)
                    .refreshable {
                        await viewModel.load(date: nil)
                    }.task {
                        await viewModel.load(date: nil)
                    }.onChange(of: viewModel.selectedDate, perform: { newValue in
                        Task {
                            await viewModel.load(date: newValue)
                        }
                    }).navigationDestination(for: ZermeloLivescheduleAppointment.self) { appointment in
                        AppointmentView(item: appointment)
                    }
                    .analyticsScreen(name: "Week")
            }
        }
    }
    
    func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .full
        return dateFormatter.string(from: date)
    }
}

//struct WeekView_Previews: PreviewProvider {
//    static var previews: some View {
//        WeekView()
//    }
//}
