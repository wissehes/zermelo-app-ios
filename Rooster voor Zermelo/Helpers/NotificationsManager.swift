//
//  NotificationsManager.swift
//  Rooster voor Zermelo
//
//  Created by Wisse Hes on 15/01/2023.
//

import Foundation
import UserNotifications

final class NotificationsManager {
    
    /**
     Request notification permission.
     */
    static func requestPermission(completion: @escaping (Result<Bool, Error>) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if let error = error {
//                print(error.localizedDescription)
                completion(.failure(error))
            } else  {
//                print("All set!")
                completion(.success(success))
            }
        }
    }
    
    /**
     Get permission status.
     */
    static func getPermissionStatus(completion: @escaping (UNNotificationSettings) -> ()) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            completion(settings)
        }
    }
    
    /**
     Schedule notifications for an array of appointments
     */
    static func scheduleNotifications(_ appointments: [ZermeloLivescheduleAppointment]) async {
        let status = await checkStatus()
        
        if !status {
            return
        }
        
        let filtered = appointments.filter { app in app.id != nil }.filter { app in
            let date = Date(timeIntervalSince1970: TimeInterval(app.start))
            let now = Date()
            return date > now
        }
        
        self.getNotifications { scheduled in
            
            for appointment in filtered {
                if scheduled.first(where: { self.filterFunction($0, app: appointment) }) == nil {
                    self.scheduleNotification(appointment)
                }
            }
        }
    }
    
    /**
     Filter function for the `scheduleNotifications` function
     */
    static private func filterFunction(_ notification: UNNotificationRequest, app: ZermeloLivescheduleAppointment) -> Bool {
        if let id = app.id {
            return notification.identifier == String(describing: id)
        } else {
            return false
        }
    }
    
    /**
     Schedule a notification for an appointment
     */
    static func scheduleNotification(_ appointment: ZermeloLivescheduleAppointment) {
        // If there's no id, return, because we need the identifier.
        guard let id = appointment.id else { return }
        
        // Create the content
        let content = self.getNotificationContent(appointment)
        content.sound = UNNotificationSound.default
        
        
        let startDate = Date(timeIntervalSince1970: TimeInterval(appointment.start))

        // Create dateComponents from the date minus 5 minutes.
        guard let newDate = Calendar.current.date(byAdding: .minute, value: -5, to: startDate) else { return }
        let dateComps = Calendar.current.dateComponents([.minute, .hour, .day, .month, .year], from: newDate)
        // Create the trigger from the dateComponents
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComps, repeats: false)
        
        let request = UNNotificationRequest(identifier: String(describing: id), content: content, trigger: trigger)
        
        // add our notification request
        UNUserNotificationCenter.current().add(request)
    }
    
    /**
     Generate notification content from appointment
     */
    static func getNotificationContent(_ appointment: ZermeloLivescheduleAppointment) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        // Variables for notification content
        let subjects = appointment.subjects.joined(separator: ",")
        let location = appointment.locations.joined(separator: ",")
        let teachers = appointment.teachers.joined(separator: ", ")
        let date = Date(timeIntervalSince1970: TimeInterval(appointment.start))
        let formattedDate = date.formatted(date: .omitted, time: .shortened)
        
        // Set the notification content
        content.title = String(localized: "notification.title \(subjects)");
        content.body = String(localized: "notification.body \(formattedDate) \(subjects) \(location) \(teachers)")
        
        return content
    }
    
    /**
     Remove all pending notifications
     */
    static func removeAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    /**
     Get all pending notifications
     */
    static func getNotifications(completion: @escaping ([UNNotificationRequest]) -> ()) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { notifications in
            completion(notifications)
        }
    }
    
    // Check if
    // a) notifications are enabled
    // b) we have the permission to send notifications
    static func checkStatus() async -> Bool {
        return await withCheckedContinuation { continuation in
            let enabled = UserDefaults.standard.bool(forKey: "showNotifications")
            
            if enabled {
                self.getPermissionStatus { settings in
                    if settings.authorizationStatus == .authorized {
                        continuation.resume(returning: true)
                    } else {
                        continuation.resume(returning: false)
                    }
                }
            } else {
                continuation.resume(returning: false)
            }
        }
    }
    
    static func setNotificationUser(id: String) {
        UserDefaults.standard.set(id, forKey: "notificationsuser")
    }
    
    static func getNotificationsUserId() -> String {
        return UserDefaults.standard.string(forKey: "notificationsuser") ?? ""
    }
}
