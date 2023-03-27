//
//  AppointmentView.swift
//  Rooster voor Zermelo
//
//  Created by Wisse Hes on 05/09/2022.
//

import SwiftUI
import FirebaseAnalytics
import AlertToast

struct AppointmentView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isShowingToast = false
    @State private var saveError: String?
    
    var item: ZermeloLivescheduleAppointment
    var date: Date {
        return Date(timeIntervalSince1970: TimeInterval(item.start))
    }
    
    var body: some View {
            List {
                
                statusView
                
                infoSection
                
                Section("calendar.add") {
                    Button {
                        Task {
                            do {
                                try await item.addToDeviceCalendar()
                            } catch AddToCalendarError.accessDenied {
                                self.saveError = String(localized: "calendar.accessDenied")
                            } catch AddToCalendarError.noSubjects {
                                self.saveError = String(localized: "calendar.empty")
                            } catch {
                                self.saveError = error.localizedDescription
                            }
                            self.isShowingToast = true
                        }
                    } label: {
                        Label("calendar.add", systemImage: "calendar.badge.plus")
                    }

                }
                                
                otherSection
                
            }.navigationTitle("appointment.appointment")
            .analyticsScreen(name: "Appointment", extraParameters: ["subject": item.subjects.join()])
            .toast(isPresenting: $isShowingToast) {
                if let error = saveError {
                    return AlertToast(displayMode: .banner(.slide), type: .error(.red), title: error)
                } else {
                    return AlertToast(displayMode: .alert, type: .complete(.green), title: "calendar.added.title", subTitle: "calendar.added.subtitle")
                }
            } onTap: {
                if saveError == nil {
                    item.showInCalendar()
                }
            } completion: {
                self.saveError = nil
            }
    }
    
    @ViewBuilder
    var statusView:  some View {
        if !(item.content?.isEmpty ?? true) ||
            !(item.changeDescription?.isEmpty ?? true) ||
            !(item.schedulerRemark?.isEmpty ?? true) {
            Section("Info") {
                if let teacherRemark = item.content, !teacherRemark.isEmpty {
                    Label(teacherRemark, systemImage: "text.bubble")
                        .symbolRenderingMode(.hierarchical)
                        .tint(.pink)
                }
                if let remark = item.schedulerRemark, !remark.isEmpty {
                    Label(remark, systemImage: "info.bubble")
                        .symbolRenderingMode(.hierarchical)
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
//            itemDetailView(
//                SubjectManager.shared.getFullName(item.subjects),
//                icon: "graduationcap",
//                single:"appointment.subjects.single",
//                multiple: "appointment.subjects.multiple"
//            )
            SubjectTextView(subjects: item.subjects)
            
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
                    .multilineTextAlignment(.trailing)
            } else {
                Text(value.joined(separator: ", "))
                    .font(.system(.body, design: .monospaced))
                    .multilineTextAlignment(.trailing)
            }
        }
    }
}

struct AppointmentView_Previews: PreviewProvider {
    static var previews: some View {
        AppointmentView(item: .example)
    }
}
