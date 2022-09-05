//
//  HomeView.swift
//  Rooster voor Zermelo
//
//  Created by Wisse Hes on 04/09/2022.
//

import SwiftUI
import Alamofire

struct HomeView: View {    
    // Only use `didSet` on `me` because it is the last
    // thing set, after the token.
    var me: ZermeloMeData {
        didSet {
            viewModel.load(me: me)
        }
    }
    
    var signOut: () -> ()
    
    @StateObject var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    todayView
                }
            }.navigationTitle("Home")
                .toolbar {
                    ToolbarItem(placement: .destructiveAction) {
                        Button("Uitloggen") {
                            signOut()
                        }
                    }
                }
        }.onAppear { viewModel.load(me: me) }
        
    }
    
    func timeView(appointment: ZermeloLivescheduleAppointment) -> some View {
        let start = Date(timeIntervalSince1970: TimeInterval(appointment.start))
        let endDate = Date(timeIntervalSince1970: TimeInterval(appointment.end))
                                            
        return Text("\(start, style: .time) - \(endDate, style: .time)")
    }
    
    func itemDetailView(_ item: ZermeloLivescheduleAppointment) -> some View {
        NavigationView {
            List {
                Section("Info") {
                    itemDetailViewDetails([item.startTimeSlotName], single: "Blok:", multiple: nil)
                    itemDetailViewDetails(item.subjects, single:"Vak:", multiple: "Vakken:")
                    itemDetailViewDetails(item.teachers, single: "Docent:", multiple: "Docenten:")
                    itemDetailViewDetails(item.locations, single: "Locatie:", multiple: "Locaties:")
                    itemDetailViewDetails(item.groups, single: "Groep:", multiple: "Groepen:")
                }
                
                if let actions = item.actions {
                    Section("Andere Keuzes") {
                        ForEach(actions, id: \.post) { item in
                            Text(item.appointment.subjects.joined(separator: ", "))
                        }
                    }
                }
            }.navigationTitle("Blokinformatie")
        }
    }
    
    func itemDetailViewDetails(_ value: [String], single: String, multiple: String?) -> some View {
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
    
    func itemView(_ item: ZermeloLivescheduleAppointment) -> some View {
        HStack {
            Text(item.startTimeSlotName)
                .fontWeight(.bold)
                .frame(width: 25, height: 25, alignment: .center)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.accentColor, lineWidth: 5)
                        .padding(5)
                )
            
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
            }
        }.onTapGesture {
            viewModel.showItemDetails(item)
        }
    }
    
    var todayView: some View {
        List(viewModel.todayAppointments, id: \.start) { item in
            itemView(item)
                .sheet(isPresented: $viewModel.appointmentDetailsShown) {
                    if let item = viewModel.selectedAppointment {
                        itemDetailView(item)
                    }
                }
        }
    }
}

            //struct HomeView_Previews: PreviewProvider {
            //    static var previews: some View {
            //        HomeView(token: ., me: .constant(nil))
            //    }
            //}
