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
    
    @EnvironmentObject var authManager: AuthManager
    
    @StateObject var viewModel = HomeViewModel()
    
    func showItemDetails(_ item: ZermeloLivescheduleAppointment) {
        viewModel.selectedAppointment = item
        viewModel.appointmentDetailsShown = true
    }
    
    var body: some View {
        NavigationStack {
            todayView
                .navigationTitle("Home")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink {
                            AboutView()
                        } label: {
                            Label("Over deze app", systemImage: "info.circle")
                        }
                    }
                }
        }.navigationDestination(for: ZermeloLivescheduleAppointment.self) { appointment in
            AppointmentView(item: appointment)
        }.task {
            guard let me = authManager.me else { return }
            await viewModel.load(me: me)
        }.refreshable {
            await viewModel.reload()
        }
    }
    
    @ViewBuilder
    var todayView: some View {
        if viewModel.todayAppointments.isEmpty {
            VStack {
                Image(systemName: "calendar.badge.exclamationmark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 75, height: 75)
                    .foregroundColor(.secondary)
                
                Text("Geen afspraken gevonden.")
                    .font(.title)
                    .foregroundColor(.secondary)
            }
        } else {
            List {
                Section("Vandaag") {
                    DayView(appointments: viewModel.todayAppointments)
                }.headerProminence(.increased)
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(AuthManager())
    }
}
