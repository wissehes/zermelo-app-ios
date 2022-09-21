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
        NavigationView {
            List {
                
                statusView
                
                infoSection
                
                Section("Andere Keuzes") {
                    
                    if !item.subjects.isEmpty {
                        
                        HStack {
                            
                            Label("Ingeschreven", systemImage: "checkmark.square")
                                .foregroundColor(.green)
                                .labelStyle(.iconOnly)
                            
                            VStack(alignment: .leading) {
                                Text("**\(item.subjects.joined())** - \(item.locations.joined()) - \(item.teachers.joined())")
                                
                                Text("Ingeschreven")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    if item.actions == nil {
                        Text("Geen andere keuzes.")
                            .foregroundColor(.secondary)
                    }
                    
                    if let actions = item.actions {
                        if actions.isEmpty {
                            Text("Geen andere keuzes.")
                                .foregroundColor(.secondary)
                        }
                        
                        ForEach(actions, id: \.post) { item in
                            actionView(action: item)
                        }
                    }
                }
            }.navigationTitle("Blokinformatie")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button { presentationMode.wrappedValue.dismiss() } label: {
                            Label("Sluiten", systemImage: "xmark.circle")
                        }
                    }
                }
        }
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
            itemDetailView([item.startTimeSlotName], icon: "clock", single: "Blok:", multiple: nil)
            itemDetailView(item.subjects, icon: "graduationcap", single:"Vak:", multiple: "Vakken:")
            itemDetailView(item.teachers, icon: "person", single: "Docent:", multiple: "Docenten:")
            itemDetailView(item.locations, icon: "location", single: "Locatie:", multiple: "Locaties:")
            itemDetailView(item.groups, icon: "person.3.sequence", single: "Groep:", multiple: "Groepen:")
            
            HStack {
                Label("Datum", systemImage: "calendar")
                    .fontWeight(.bold)
                Spacer()
                
                Text(date, style: .date)
            }
            
        }
    }
    
    func actionView(action: ZermeloLivescheduleAction) -> some View {
        
        HStack {
            
            if action.allowed {
                Label("Toegestaan", systemImage: "circle")
                    .labelStyle(.iconOnly)
            } else {
                Label("Niet toegestaan", systemImage: "circle.slash")
                    .foregroundColor(.red)
                    .labelStyle(.iconOnly)
            }
            
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
    }
    
    func itemDetailView(_ value: [String], icon: String, single: String, multiple: String?) -> some View {
        HStack {
            Label(value.count == 1 ? single : multiple ?? single, systemImage: icon)
                .fontWeight(.bold)
            Spacer()
            if value.isEmpty {
                Text("Geen/niet beschikbaar")
                    .italic()
            } else {
                Text(value.joined(separator: ", "))
                    .font(.system(.body, design: .monospaced))
            }
        }
    }
}
