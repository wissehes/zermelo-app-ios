//
//  WeekView.swift
//  Rooster voor Zermelo
//
//  Created by Wisse Hes on 06/09/2022.
//

import SwiftUI

struct WeekView: View {
    @EnvironmentObject var authManager: AuthManager
    
    @StateObject var viewModel = WeekViewModel()
    let tomorrow = Date().addingTimeInterval(24 * 60 * 60)
    
    func showItemDetails(_ item: ZermeloLivescheduleAppointment) {
        viewModel.selectedAppointment = item
        viewModel.appointmentDetailsShown = true
    }
    
    func scrollToToday(_ proxy: ScrollViewProxy) {
        let todayDate = viewModel.days.first(where: { Calendar.current.isDateInToday($0.date) })
        if let todayDate = todayDate {
            withAnimation {
                proxy.scrollTo(todayDate.date.ISO8601Format(), anchor: .center)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollViewReader { proxy in
                List {
                    ForEach(viewModel.days, id: \.date.timeIntervalSince1970) { day in
                        Section {
                            DayView(appointments: day.appointments, showDetails: showItemDetails)
                        } header: {
                            if Calendar.current.isDateInToday(day.date) {
                                Text("Vandaag (\(day.date, style: .date))")
                            } else if Calendar.current.isDate(tomorrow, equalTo: day.date, toGranularity: .day) {
                                Text("Morgen (\(day.date, style: .date)")
                            } else {
                                Text(formatDate(day.date))
                            }
                        }.textCase(nil)
                            .headerProminence(.increased)
                            .id(day.date.ISO8601Format())
                    }
                }.navigationTitle("Week")
                    .toolbar {
                        ToolbarItem(placement: .primaryAction) {
                            Button("Vandaag") { scrollToToday(proxy) }
                        }
                        ToolbarItem(placement:.bottomBar) {
                            DatePicker("Week", selection: $viewModel.selectedDate, displayedComponents: .date)
                        }
                    }
                    .listStyle(.sidebar)
                    .refreshable {
                        guard let me = authManager.me else { return }
                        await viewModel.load(me: me, proxy: proxy, date: nil)
                    }.task {
                        guard let me = authManager.me else { return }
                        await viewModel.load(me: me, proxy: proxy, date: nil)
                    }.onChange(of: viewModel.selectedDate, perform: { newValue in
                        Task {
                            guard let me = authManager.me else { return }
                            await viewModel.load(me: me, proxy: proxy, date: newValue)
                        }
                    }).sheet(isPresented: $viewModel.appointmentDetailsShown) {
                        if let item = viewModel.selectedAppointment {
                            AppointmentView(item: item)
                        }
                    }
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
