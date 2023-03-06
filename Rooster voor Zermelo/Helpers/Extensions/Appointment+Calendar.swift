//
//  Appointment+Calendar.swift
//  Rooster voor Zermelo
//
//  Created by Wisse Hes on 06/03/2023.
//

import Foundation
import EventKit
import UIKit

extension ZermeloLivescheduleAppointment {
    enum AddToCalendarError: Error {
        case accessDenied
        case noSubjects
    }
    
    func addToDeviceCalendar() async throws {
        let eventStore = EKEventStore()

        let permission = try await eventStore.requestAccess(to: .event)
        
        if permission {
            let event = EKEvent(eventStore: eventStore)
            
            guard !self.subjects.isEmpty else { throw AddToCalendarError.noSubjects }
            let startDate = Date(timeIntervalSince1970: TimeInterval(self.start))
            let endDate = Date(timeIntervalSince1970: TimeInterval(self.end))
            
            event.calendar = eventStore.defaultCalendarForNewEvents
            event.title = SubjectManager.shared.getFullName(self.subjects).join(.normal)
            event.startDate = startDate
            event.endDate = endDate
            if !self.locations.isEmpty {
                event.location = self.locations.join(.normal)
            }
            if let status = self.status {
                event.location = status.map { $0.nl }.joined(separator: "\n")
            }
            
            try eventStore.save(event, span: .thisEvent)
            
            let interval = Date().timeIntervalSinceReferenceDate
            DispatchQueue.main.async {
                UIApplication.shared.open(URL(string: "calshow:\(interval)")!, options: [:])
            }            
        } else {
            throw AddToCalendarError.accessDenied
        }
    }
}
