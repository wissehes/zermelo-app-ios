//
//  AppointmentActionView.swift
//  Rooster voor Zermelo
//
//  Created by Wisse Hes on 27/09/2022.
//

import SwiftUI
import Alamofire

struct AppointmentActionView: View {
    var action: ZermeloLivescheduleAction
    @EnvironmentObject var authManager: AuthManager
//    @Environment(\.locale) var locale
    
    @State var isLoading = false
    
    var statuses: [String] {
        // Use Locale.current to get the current locale
        if Locale.current.identifier == "nl" {
            return action.status.map { $0.nl }
        } else {
            return action.status.map { $0.en }
        }
    }
    
    var body: some View {
        HStack {
            // Icon
            label
            
            // Information
            info
        }
    }
    
    
    var info: some View {
        VStack(alignment: .leading) {
            if let app = action.appointment {
                Text("**\(app.subjects.joined(separator: ","))** - \(app.locations.joined(separator: ",")) - \(app.teachers.joined(separator: ","))")
            }
            
            ForEach(statuses, id: \.self) { status in
                Text(status)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    @ViewBuilder
    var label: some View {
        if isLoading {
            ProgressView()
        } else if action.allowed {
            Label("appointment.action.status.allowed", systemImage: "circle")
                .labelStyle(.iconOnly)
        } else {
            Label("appointment.action.status.notAllowed", systemImage: "circle.slash")
                .foregroundColor(.red)
                .labelStyle(.iconOnly)
        }
    }
}

//struct AppointmentActionView_Previews: PreviewProvider {
//    static var previews: some View {
//        AppointmentActionView()
//    }
//}
