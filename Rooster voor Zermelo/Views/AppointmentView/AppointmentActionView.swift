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
    
    @State var isLoading = false
    
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
                Text("**\(app.subjects.joined())** - \(app.locations.joined()) - \(app.teachers.joined())")
            }
            
            if !action.status.isEmpty {
                Text(action.status.map { $0.nl }.joined())
                    .foregroundColor(.secondary)
            }
        }
    }
    
    @ViewBuilder
    var label: some View {
        if isLoading {
            ProgressView()
        } else if action.allowed {
            Label("Toegestaan", systemImage: "circle")
                .labelStyle(.iconOnly)
        } else {
            Label("Niet toegestaan", systemImage: "circle.slash")
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
