//
//  CompareView.swift
//  Rooster voor Zermelo
//
//  Created by Wisse Hes on 30/01/2023.
//

import SwiftUI

struct CompareView: View {
    @EnvironmentObject var authManager: AuthManager
    @StateObject var vm = CompareViewModel()
    
    
    var body: some View {
        List {
            Section("Accounts") {
                Picker("Account 1", selection: $vm.user1) {
                    ForEach(vm.users, id: \.id) { user in
                        Text(user.name)
                            .tag(user as User?)
                    }
                }
                
                Picker("Account 2", selection: $vm.user2) {
                    ForEach(vm.users, id: \.id) { user in
                        Text(user.name)
                            .tag(user as User?)
                    }
                }
                
                DatePicker("Dag", selection: $vm.date, displayedComponents: .date)
                
                Button {
                    Task {
                        await vm.compare()
                    }
                } label: {
                    switch vm.isLoading {
                    case true:
                        HStack {
                            Label("Vergelijken", systemImage: "checkmark.circle")
                            Spacer()
                            ProgressView()
                        }
                    case false:
                        Label("Vergelijken", systemImage: "checkmark.circle")
                    }
                }.disabled(vm.isLoading)
            }
            
            Section("Blokken samen") {
                ForEach(vm.matchingAppointments, id: \.start) { item in
                    DayItemView(item: item)
                }
            }
            
            Section("Blokken niet samen") {
                if let user1 = vm.user1 {
                    Section(user1.name ) {
                        ForEach(vm.seperateForUser1, id: \.id) { appointment in
                            DayItemView(item: appointment)
                        }
                    }
                }
                
                if let user2 = vm.user2 {
                    Section(user2.name ) {
                        ForEach(vm.seperateForUser2, id: \.id) { appointment in
                            DayItemView(item: appointment)
                        }
                    }
                }
            }
        }
        .navigationDestination(for: ZermeloLivescheduleAppointment.self) { appointment in
            AppointmentView(item: appointment)
        }
    }
}

struct CompareView_Previews: PreviewProvider {
    static var previews: some View {
        CompareView()
    }
}

final class CompareViewModel: ObservableObject {
    @Published var users: [User] = []
    
    @Published var user1: User?
    @Published var user2: User?
    
    @Published var matchingAppointments: [ZermeloLivescheduleAppointment] = []
    @Published var seperateForUser1: [ZermeloLivescheduleAppointment] = []
    @Published var seperateForUser2: [ZermeloLivescheduleAppointment] = []
    
    @Published var isLoading: Bool = false
    @Published var date: Date = .now
    
    init(){
        self.users = UserManager.getAll()
        
        self.user1 = self.users.first
        self.user2 = self.users.last
    }
    
    func compare() async {
        guard let user1 = user1 else { return print("no user1") }
        guard let user2 = user2 else { return print("no user2") }
        if user1 == user2 {
            return
        }
        DispatchQueue.main.async {
            self.reset()
            self.isLoading = true
        }
        
        defer {
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
        
        guard let user1Schedule = try? await API.getLiveSchedule(user: user1, week: API.getWeek(date)).filter(isinToday) else { return }
        try? await Task.sleep(for: .seconds(1))
        guard let user2Schedule = try? await API.getLiveSchedule(user: user2, week: API.getWeek(date)).filter(isinToday) else { return }
        
        for appointment in user1Schedule {
            DispatchQueue.main.async {
                if let foundMatching = user2Schedule.first(where: {
                    appointment.start == $0.start &&
                    appointment.teachers == $0.teachers &&
                    appointment.subjects == $0.subjects &&
                    appointment.locations == $0.locations &&
                    appointment.end == $0.end
                }) {
                    self.matchingAppointments.append(foundMatching)
                } else {
                    self.seperateForUser1.append(appointment)
                    if let user2Seperate = user2Schedule.first(where: {
                        appointment.start == $0.start
                    }) {
                        self.seperateForUser2.append(user2Seperate)
                    }
                }
            }
        }
    }
    
    private func isinToday(_ app: ZermeloLivescheduleAppointment) -> Bool {
        if app.subjects.isEmpty {
            return false
        }
        let start = Date(timeIntervalSince1970: TimeInterval(app.start))
        return Calendar.current.isDate(start, inSameDayAs: self.date)
    }
    
    private func reset() {
        self.matchingAppointments = []
        self.seperateForUser1 = []
        self.seperateForUser2 = []
    }
}
