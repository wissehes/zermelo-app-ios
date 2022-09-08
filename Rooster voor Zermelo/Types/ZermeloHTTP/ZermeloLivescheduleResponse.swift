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
struct ZermeloLivescheduleAppointment: Codable {
    let status: [ZermeloLivescheduleStatus]?
    let actions: [ZermeloLivescheduleAction]?
    let start, end: Int
    let cancelled: Bool
    let appointmentType: String
    let online, appointmentOptional: Bool
    let appointmentInstance: Int?
    let startTimeSlotName, endTimeSlotName: String
    let subjects, groups, locations, teachers: [String]
    let changeDescription, schedulerRemark: String?
    let id: Int?
    let plannedAttendance, studentEnrolled: Bool?
    let allowedActions: String?
    let attendanceOverruled: Bool?
    let availableSpace: Int?
    
    //    let onlineTeachers: [JSONAny]
    //    let onlineLocationURL, capacity, expectedStudentCount, expectedStudentCountOnline: JSONNull?
    //    let content: JSONNull?

    enum CodingKeys: String, CodingKey {
        case status, actions, start, end, cancelled, appointmentType, online
        case appointmentOptional = "optional"
        case appointmentInstance, startTimeSlotName, endTimeSlotName, subjects, groups, locations, teachers
        case changeDescription, schedulerRemark, id, plannedAttendance, studentEnrolled, allowedActions, attendanceOverruled, availableSpace
        
//        case onlineTeachers
//        case expectedStudentCountOnline
//        case expectedStudentCount
//        case capacity
//        case onlineLocationURL = "onlineLocationUrl"
//        case content
    }
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
//enum ZermeloLivescheduleAppointmentType: String, Codable {
//    case choice = "choice"
//    case lesson = "lesson"
//}
//
