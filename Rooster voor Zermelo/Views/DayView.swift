//
//  DayView.swift
//  Rooster voor Zermelo
//
//  Created by Wisse Hes on 06/09/2022.
//

import SwiftUI

struct DayView: View {
    var appointments: [ZermeloLivescheduleAppointment]
    
    var showDetails: (ZermeloLivescheduleAppointment) -> ()
        
    init(appointments: [ZermeloLivescheduleAppointment], showDetails: @escaping (ZermeloLivescheduleAppointment) -> ()) {
        self.appointments = appointments.sorted(by: { app1, app2 in
            let date1 = Date(timeIntervalSince1970: TimeInterval(app1.start))
            let date2 = Date(timeIntervalSince1970: TimeInterval(app2.start))
            
            return date1.compare(date2) == .orderedAscending
        })
        
        self.showDetails = showDetails
    }
    
    var body: some View {
        ForEach(appointments, id: \.start) { item in
            DayItemView(item: item, showDetails: showDetails)
        }
    }
}

struct DayItemView: View {
    
    @Environment(\.colorScheme) var colorScheme

    
    var item: ZermeloLivescheduleAppointment
    var showDetails: (ZermeloLivescheduleAppointment) -> ()
    
    var isRightNow: Bool {
        let start = Date(timeIntervalSince1970: TimeInterval(item.start))
        let end = Date(timeIntervalSince1970: TimeInterval(item.end))
        
        return start.timeIntervalSince1970 < Date().timeIntervalSince1970 && Date().timeIntervalSince1970 < end.timeIntervalSince1970
    }
    
    func timeView(appointment: ZermeloLivescheduleAppointment) -> some View {
        let start = Date(timeIntervalSince1970: TimeInterval(appointment.start))
        let endDate = Date(timeIntervalSince1970: TimeInterval(appointment.end))
        
        return Text("\(start, style: .time) - \(endDate, style: .time)")
    }
    
    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.accentColor, lineWidth: 5)
                .background(RoundedRectangle(cornerRadius: 10).fill(isRightNow ? Color("TimeSlotColor") : colorScheme == .light ? .white : .black))
                .overlay(
                    Text(item.startTimeSlotName)
                        .fontWeight(.bold)
                )
                .frame(width: 50, height: 50, alignment: .center)
                .padding(5)
            
            VStack(alignment: .leading) {
                
                HStack {
                    if !item.subjects.isEmpty {
                        Text(item.subjects.joined(separator: ", "))
                            .font(.headline)
                    } else {
                        Text("Leeg")
                            .italic()
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    
                    if(!item.teachers.isEmpty) {
                        Text("-")
                        Text(item.teachers.joined(separator: ", "))
                    }
                    if(!item.locations.isEmpty) {
                        Text("-")
                        Text(item.locations.joined(separator: ", "))
                    }
                }
                
                timeView(appointment: item)
                    .font(.subheadline)
                
                if let desc = item.changeDescription {
                    if !desc.isEmpty {
                        Text(desc)
                            .font(.subheadline)
                            .italic()
                    }
                }
            }
            Spacer()
            Button {
                showDetails(item)
            } label: {
                Label("Info", systemImage: "info.circle")
                    .labelStyle(.iconOnly)
            }
            
        }
    }
}

//struct DayView_Previews: PreviewProvider {
//    static var previews: some View {
//        DayView()
//    }
//}
