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
        request.earliestBeginDate = .now.addingTimeInterval(12 * 3600)
        try? BGTaskScheduler.shared.submit(request)
    }
}
