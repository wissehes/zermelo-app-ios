//
//  DayView.swift
//  Rooster voor Zermelo
//
//  Created by Wisse Hes on 06/09/2022.
//

import SwiftUI

struct DayView: View {
    var appointments: [ZermeloLivescheduleAppointment]
    
    init(appointments: [ZermeloLivescheduleAppointment]) {
        self.appointments = appointments.sorted(by: { app1, app2 in
            let date1 = Date(timeIntervalSince1970: TimeInterval(app1.start))
            let date2 = Date(timeIntervalSince1970: TimeInterval(app2.start))
            
            return date1.compare(date2) == .orderedAscending
        })
    }
    
    var body: some View {
        ForEach(appointments, id: \.start) { item in
            DayItemView(item: item)
        }
    }
}

//struct DayView_Previews: PreviewProvider {
//    static var previews: some View {
//        DayView()
//    }
//}
