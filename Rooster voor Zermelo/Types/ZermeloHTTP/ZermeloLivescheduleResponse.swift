//
//  ZermeloLivescheduleResponse.swift
//  Rooster voor Zermelo
//
//  Created by Wisse Hes on 04/09/2022.
//

import Foundation

// MARK: - GetZermeloLiveschedule
struct GetZermeloLiveschedule: Codable {
    let response: ZermeloLivescheduleResponse
}

// MARK: - ZermeloLivescheduleResponse
struct ZermeloLivescheduleResponse: Codable {
    let status: Int
    let message, details: String
    let eventID, startRow, endRow, totalRows: Int
    let data: [ZermeloLivescheduleData]

    enum CodingKeys: String, CodingKey {
        case status, message, details
        case eventID = "eventId"
        case startRow, endRow, totalRows, data
    }
}

// MARK: - ZermeloLivescheduleData
struct ZermeloLivescheduleData: Codable {
    let week, user: String
    let appointments: [ZermeloLivescheduleAppointment]
    let status: [ZermeloLivescheduleStatus]
//    let replacements: [JSONAny]
}

// MARK: - ZermeloLivescheduleAction
struct ZermeloLivescheduleAction: Codable {
    let appointment: ZermeloLivescheduleAppointment?
    let status: [ZermeloLivescheduleStatus]
    let allowed: Bool
    let post: String
}

// MARK: - ZermeloLivescheduleAppointment
struct ZermeloLivescheduleAppointment: Codable, Hashable {
    static func == (lhs: ZermeloLivescheduleAppointment, rhs: ZermeloLivescheduleAppointment) -> Bool {
        if let lid = lhs.id, let rid = rhs.id {
            return lid == rid
        } else {
            return lhs.subjects == rhs.subjects && lhs.start == rhs.start
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    let status: [ZermeloLivescheduleStatus]?
    let actions: [ZermeloLivescheduleAction]?
    let start, end: Int
    let cancelled: Bool
    let appointmentType: ZermeloAppointmentType
    let online, appointmentOptional: Bool
    let appointmentInstance: Int?
    let startTimeSlotName, endTimeSlotName: String?
    let subjects, groups, locations, teachers: [String]
    let changeDescription, schedulerRemark, content: String?
    let id: Int?
    let plannedAttendance, studentEnrolled: Bool?
    let allowedActions: String?
    let attendanceOverruled: Bool?
    let availableSpace: Int?
    

    enum CodingKeys: String, CodingKey {
        case status, actions, start, end, cancelled, appointmentType, online
        case appointmentOptional = "optional"
        case appointmentInstance, startTimeSlotName, endTimeSlotName, subjects, groups, locations, teachers
        case changeDescription, schedulerRemark, content, id, plannedAttendance, studentEnrolled, allowedActions, attendanceOverruled, availableSpace
    }
    
    static var example: ZermeloLivescheduleAppointment = {
        let path = Bundle.main.path(forResource: "appointment", ofType: "json")
        let data = try? Data(contentsOf: URL(fileURLWithPath: path!), options: .mappedIfSafe)
        let app = try? JSONDecoder().decode(ZermeloLivescheduleAppointment.self, from: data!)
        return app!
    }()
}

// MARK: - ZermeloLivescheduleStatus
struct ZermeloLivescheduleStatus: Codable {
    let code: Int
    let nl: String
    let en: String
}
//
//enum ZermeloLivescheduleAllowedActions: String, Codable {
//    case none = "none"
//}
//
//enum ZermeloAppointmentType: String, Codable {
enum ZermeloAppointmentType: Codable, Equatable {
    case choice
    case lesson
    case exam
    case talk
    case other(String)
    
    init(rawValue: String) {
        switch rawValue {
        case "choice": self = .choice
        case "lesson": self = .lesson
        case "exam": self = .exam
        case "talk": self = .talk
        default: self = .other(rawValue)
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        switch string {
        case "choice": self = .choice
        case "lesson": self = .lesson
        case "exam": self = .exam
        case "talk": self = .talk
        default: self = .other(string)
        }
        
    }
}
