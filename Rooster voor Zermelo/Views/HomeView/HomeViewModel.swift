//
//  HomeViewModel.swift
//  Rooster voor Zermelo
//
//  Created by Wisse Hes on 05/09/2022.
//

import Foundation
import Alamofire

final class HomeViewModel: ObservableObject {
    @Published var todayAppointments: [ZermeloLivescheduleAppointment] = []
    @Published var isLoading = true
    
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
                self.todayAppointments = data.filter {
                    Calendar.current.isDateInToday(Date(timeIntervalSince1970: TimeInterval($0.start)))
                }
            case .failure(let failure):
                print(failure)
            }
        }
    }
}
