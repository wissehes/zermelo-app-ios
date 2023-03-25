//
//  Appointment+Calendar.swift
//  Rooster voor Zermelo
//
//  Created by Wisse Hes on 06/03/2023.
//

import Foundation
import EventKit
import UIKit

enum AddToCalendarError: Error {
    case accessDenied
    case noSubjects
}

extension ZermeloLivescheduleAppointment {
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
            event.notes = self.getAllRemarks()

            if !self.locations.isEmpty {
                event.location = self.locations.join(.normal)
            }
            
            try eventStore.save(event, span: .thisEvent)
            
//            let interval = Date().timeIntervalSinceReferenceDate
//            DispatchQueue.main.async {
//                UIApplication.shared.open(URL(string: "calshow:\(interval)")!, options: [:])
//            }
        } else {
            throw AddToCalendarError.accessDenied
        }
    }
    
    func showInCalendar() {
        let interval = Date(timeIntervalSince1970: TimeInterval(self.start)).timeIntervalSinceReferenceDate
        DispatchQueue.main.async {
            UIApplication.shared.open(URL(string: "calshow:\(interval)")!, options: [:])
        }
    }
    
    func getAllRemarks() -> String {
        var remarks: [String] = []
        
        if let teacherRemark = self.content, !teacherRemark.isEmpty {
            remarks.append(teacherRemark)
        }
        if let schedulerRemark = self.schedulerRemark, !schedulerRemark.isEmpty {
            remarks.append(schedulerRemark)
        }
        if let desc = self.changeDescription, !desc.isEmpty {
            remarks.append(desc)
        }
        
        return remarks.joined(separator: "\n")
    }
}
