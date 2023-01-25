//
//  BackgroundTasksController.swift
//  Rooster voor Zermelo
//
//  Created by Wisse Hes on 23/01/2023.
//

import Foundation
import BackgroundTasks

final class BackgroundTasksController {
    static func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "notificationrefresh")
        // Add 12 hours
//        request.earliestBeginDate = .now.addingTimeInterval(12 * 3600)
        // add 24 hours and set the time to 1 am
        let date = Date.now.addingTimeInterval(24 * 3600)
        request.earliestBeginDate = Calendar.current.date(bySettingHour: 1, minute: 00, second: 00, of: date)

        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch(let err) {
            print(err)
        }
    }
}
