//
//  DayItemView.swift
//  Rooster voor Zermelo
//
//  Created by Wisse Hes on 26/01/2023.
//

import SwiftUI

struct DayItemView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @State var date = Date()
    
    var item: ZermeloLivescheduleAppointment
    
    var isRightNow: Bool {
        let start = Date(timeIntervalSince1970: TimeInterval(item.start))
        let end = Date(timeIntervalSince1970: TimeInterval(item.end))
        
        return start.timeIntervalSince1970 < date.timeIntervalSince1970 && date.timeIntervalSince1970 < end.timeIntervalSince1970
    }
    
    func timeView(appointment: ZermeloLivescheduleAppointment) -> some View {
        let startDate = Date(timeIntervalSince1970: TimeInterval(appointment.start))
        let endDate = Date(timeIntervalSince1970: TimeInterval(appointment.end))
        let start = Text(startDate, style: .time)
        let end = Text(endDate, style: .time)
        
        return Text(verbatim: "\(start) - \(end)")
    }
    
    @ViewBuilder
    var slotImage: some View {
        if let slotName = item.startTimeSlotName, !slotName.isEmpty {
            Text(slotName)
//                .fontWeight(.bold)
                .font(.system(size: 22.5, weight: .bold, design: .rounded))
        } else if item.appointmentType == .exam {
            Image(systemName: "magazine")
        } else {
            Image(systemName: "calendar")
        }
    }
    
    var slotItem: some View {
        RoundedRectangle(cornerRadius: 10)
            .stroke(item.subjects.isEmpty ? .gray : Color.accentColor, lineWidth: 5)
            .background(RoundedRectangle(cornerRadius: 10).fill(isRightNow ? Color("TimeSlotColor") : colorScheme == .light ? .white : .black))
            .overlay(
                slotImage
            )
            .frame(width: 50, height: 50, alignment: .center)
            .padding(5)
    }
    
    var singleLine: some View {
        HStack {
            if !item.subjects.isEmpty {
                Text(item.subjects.joined(separator: ", "))
                    .font(.headline)
            } else {
                Text("word.empty")
                    .italic()
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            
            if(!item.teachers.isEmpty) {
                Text(verbatim: "-")
                Text(item.teachers.joined(separator: ", "))
            }
            if(!item.locations.isEmpty) {
                Text(verbatim: "-")
                Text(item.locations.joined(separator: ", "))
            }
        }
    }
    
    //    @ViewBuilder
    var doubleLine: some View {
        VStack(alignment: .leading) {
            if !item.subjects.isEmpty {
                Text(item.subjects.joined(separator: ", "))
                    .font(.headline)
            } else {
                Text("word.empty")
                    .italic()
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                if(!item.teachers.isEmpty) {
                    Text(item.teachers.joined(separator: ", "))
                }
                if(!item.locations.isEmpty) {
                    Text(verbatim: "-")
                    Text(item.locations.joined(separator: ", "))
                }
            }
        }
    }
    
    var body: some View {
        NavigationLink(value: item) {
            HStack {
                slotItem
                
                VStack(alignment: .leading) {
                    
                    ViewThatFits {
                        singleLine
                        doubleLine
                    }
                    
                    timeView(appointment: item)
                        .font(.subheadline)
                    
                    if let desc = item.changeDescription {
                        if !desc.isEmpty {
                            Text(desc)
                                .font(.subheadline)
                                .italic()
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                }
                Spacer()
                
                if !(item.changeDescription?.isEmpty ?? true) || item.cancelled {
                    Label(item.cancelled ? "schedule.cancelled" : "schedule.edited", systemImage: "exclamationmark.triangle.fill")
                        .labelStyle(.iconOnly)
                        .foregroundColor(item.cancelled ? .red : .yellow)
                }
            }.accentColor(item.cancelled ? .red : .accentColor)
                .onAppear {
                    self.date = Date()
                }
        }
    }
}

struct DayItemView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            List {
                DayItemView(item: .example)
            }.navigationTitle("Item")
        }
    }
}
