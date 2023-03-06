//
//  AppointmentView.swift
//  Rooster voor Zermelo
//
//  Created by Wisse Hes on 05/09/2022.
//

import SwiftUI
import FirebaseAnalytics

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
                
                Section("Add to calendar (t)") {
                    Button {
                        Task {
                            do {
                                try await item.addToDeviceCalendar()
                            } catch(let err) {
                                print(err)
                            }
                        }
                    } label: {
                        Label("Add to calendar", systemImage: "calendar.badge.plus")
                    }

                }
                                
                otherSection
                
            }.navigationTitle("appointment.appointment")
            .analyticsScreen(name: "Appointment", extraParameters: ["subject": item.subjects.join()])
    }
    
    @ViewBuilder
    var statusView:  some View {
        if item.changeDescription != "" || item.schedulerRemark != "" {
            Section("Info") {
                if let teacherRemark = item.content, !teacherRemark.isEmpty {
                    Label(teacherRemark, systemImage: "exclamationmark.bubble.fill")
                }
                if let remark = item.schedulerRemark, !remark.isEmpty {
                    Label(remark, systemImage: "exclamationmark.bubble.fill")
                }
                if let desc = item.changeDescription, !desc.isEmpty {
                        Label {
                            Text(desc)
                        } icon: {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(.yellow)
                        }

                }
            }

        }
    }
    
    var infoSection: some View {
        Section("Les") {
            if let slotName = item.startTimeSlotName, !slotName.isEmpty {
                itemDetailView([slotName], icon: "clock", single: "appointment.period", multiple: nil)
            }
            
            itemDetailView(
                SubjectManager.shared.getFullName(item.subjects),
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
    
    var otherSection: some View {
        Section {
            
            if !item.subjects.isEmpty {
                
                HStack {
                    
                    Label("appointment.enrolled", systemImage: "checkmark.circle")
                        .foregroundColor(.green)
                        .labelStyle(.iconOnly)
                    
                    VStack(alignment: .leading) {
                        Text("**\(item.subjects.join(.minimal))** - \(item.locations.join(.minimal)) - \(item.teachers.join(.minimal))")
                        
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

struct AppointmentView_Previews: PreviewProvider {
//    static var data: ZermeloLivescheduleAppointment {
//        let path = Bundle.main.path(forResource: "appointment", ofType: "json")
//        let data = try? Data(contentsOf: URL(fileURLWithPath: path!), options: .mappedIfSafe)
//        let decodedAppt = try? JSONDecoder().decode(ZermeloLivescheduleAppointment.self, from: data!)
//        return decodedAppt!
//    }
    
    static var previews: some View {
        AppointmentView(item: .example)
    }
}
