//
//  AppointmentView.swift
//  Rooster voor Zermelo
//
//  Created by Wisse Hes on 05/09/2022.
//

import SwiftUI

struct AppointmentView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    var item: ZermeloLivescheduleAppointment
    var date: Date {
        return Date(timeIntervalSince1970: TimeInterval(item.start))
    }
    
    var body: some View {
            List {
                
                statusView
                
                infoSection
                                
                Section {
                    
                    if !item.subjects.isEmpty {
                        
                        HStack {
                            
                            Label("appointment.enrolled", systemImage: "checkmark.square")
                                .foregroundColor(.green)
                                .labelStyle(.iconOnly)
                            
                            VStack(alignment: .leading) {
                                Text("**\(item.subjects.joined())** - \(item.locations.joined()) - \(item.teachers.joined())")
                                
                                Text("appointment.enrolled")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    if item.actions == nil {
                        Text("appointment.noOtherChoices")
                            .foregroundColor(.secondary)
                    }
                    
                    if let actions = item.actions {
                        if actions.isEmpty {
                            Text("appointment.noOtherChoices")
                                .foregroundColor(.secondary)
                        }
                        
                        ForEach(actions, id: \.post) { item in
                            AppointmentActionView(action: item)
                        }
                    }
                } header: {
                    Text("appointment.otherChoices")
                } footer: {
                    Text("appointment.cannotEnroll")
                }
            }.navigationTitle("appointment.appointment")
    }
    
    @ViewBuilder
    var statusView:  some View {
        if let desc = item.changeDescription, !desc.isEmpty {
            Section("Status") {
                Label {
                    Text(desc)
                } icon: {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.yellow)
                }

            }
        }
    }
    
    var infoSection: some View {
        Section("Info") {
            itemDetailView([item.startTimeSlotName], icon: "clock", single: "appointment.period", multiple: nil)
            
            itemDetailView(
                item.subjects,
                icon: "graduationcap",
                single:"appointment.subjects.single",
                multiple: "appointment.subjects.multiple"
            )
            
            itemDetailView(
                item.teachers,
                icon: "person",
                single: "appointment.teacher.single",
                multiple: "appointment.teacher.multiple"
            )
            
            itemDetailView(
                item.locations,
                icon: "location",
                single: "appointment.location.single",
                multiple: "appointment.location.multiple"
            )
            
            itemDetailView(
                item.groups,
                icon: "person.3.sequence",
                single: "appointment.group.single",
                multiple: "appointment.group.multiple"
            )
            
            HStack {
                Label("word.date", systemImage: "calendar")
                    .fontWeight(.bold)
                Spacer()
                
                Text(date, style: .date)
            }
            
        }
    }
    
    func itemDetailView(_ value: [String], icon: String, single: LocalizedStringKey, multiple: LocalizedStringKey?) -> some View {
        HStack {
            Label(value.count == 1 ? single : multiple ?? single, systemImage: icon)
                .fontWeight(.bold)
            Spacer()
            if value.isEmpty {
                Text("word.none")
                    .italic()
            } else {
                Text(value.joined(separator: ", "))
                    .font(.system(.body, design: .monospaced))
            }
        }
    }
}
