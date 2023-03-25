//
//  ActionService.swift
//  Rooster voor Zermelo
//
//  Created by Wisse Hes on 25/03/2023.
//

import Foundation
import UIKit

enum Action: String {
    case todayAction
    case tomorrowAction
    case weekAction
}

class ActionService: ObservableObject {
    static let shared = ActionService()
    
    @Published var action: Action?
    
    func handleAction(shortcutItem: UIApplicationShortcutItem) {
        guard let action = Action(rawValue: shortcutItem.type) else {
              return
        }
        self.action = action
    }
}

