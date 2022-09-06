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
                    TabView {
                        todayView
                            .tabItem {
                                Label("Vandaag", systemImage: "calendar")
                            }
                    }
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
                viewModel.showItemDetails(item)
            } label: {
                Label("Info", systemImage: "info.circle")
                    .labelStyle(.iconOnly)
            }
            
        }
    }
    
    var todayView: some View {
        List {
            Section("Vandaag") {
                ForEach(viewModel.todayAppointments, id: \.start) { item in
                    itemView(item)
                        .sheet(isPresented: $viewModel.appointmentDetailsShown) {
                            if let item = viewModel.selectedAppointment {
                                AppointmentView(item: item)
                            }
                        }
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
