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
    
    var body: some View {
        NavigationView {
            List {
                Section("Info") {
                    itemDetailView([item.startTimeSlotName], single: "Blok:", multiple: nil)
                    itemDetailView(item.subjects, single:"Vak:", multiple: "Vakken:")
                    itemDetailView(item.teachers, single: "Docent:", multiple: "Docenten:")
                    itemDetailView(item.locations, single: "Locatie:", multiple: "Locaties:")
                    itemDetailView(item.groups, single: "Groep:", multiple: "Groepen:")
                }
                
                Section("Andere Keuzes") {
                    
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
    
    func actionView(action: ZermeloLivescheduleAction) -> some View {
        
        HStack {
            
            if action.allowed {
                Label("Toegestaan", systemImage: "circle")
                    .labelStyle(.iconOnly)
            } else {
                Label("Niet toegestaan", systemImage: "circle.slash")
                    .labelStyle(.iconOnly)
            }
            
            VStack(alignment: .leading) {
                Text("**\(action.appointment.subjects.joined())** - \(action.appointment.locations.joined()) - \(action.appointment.teachers.joined())")
                Text(action.status.map { $0.nl }.joined())
                    .foregroundColor(.secondary)
            }
        }
    }
    
    func itemDetailView(_ value: [String], single: String, multiple: String?) -> some View {
        HStack {
            Text(value.count == 1 ? single : multiple ?? single)
                .fontWeight(.bold)
            Spacer()
            if value.isEmpty {
                Text("Geen/niet beschikbaar")
                    .italic()
            } else {
                Text(value.joined(separator: ", "))
            }
        }
    }
}

//struct AppointmentViewPreview: View {
//
//    @State var appointment: ZermeloLivescheduleAppointment?
//
//    func load() {
//        API.getLiveSchedule(
//            me: ZermeloMeData(
//                code: "107012",
//                roles: [],
//                firstName: "",
//                lastName: ""
//            )
//        ) { result in
//            switch result {
//            case .success(let data):
//                self.appointment = data.first
//            case .failure(_):
//                          break;
//            }
//        }
//    }
//
//    @ViewBuilder
//    var body: some View {
//            if let app = appointment {
//                AppointmentView(item: app)
//            } else {
//                ProgressView()
//                    .onAppear { load() }
//        }
//    }
//}

//struct AppointmentView_Previews: PreviewProvider {
//    static var previews: some View {
//        AppointmentViewPreview()
//    }
//}
