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
                    
                    ToolbarItem(placement: .automatic) {
                        if viewModel.isLoading {
                            ProgressView()
                        }
                    }
                }
        }.onAppear {
            guard let me = authManager.me else { return }
            viewModel.load(me: me)
        }
    }
    var todayView: some View {
        List {
            Section("Vandaag") {
                DayView(appointments: viewModel.todayAppointments, showDetails: showItemDetails)
                    .sheet(isPresented: $viewModel.appointmentDetailsShown) {
                        if let item = viewModel.selectedAppointment {
                            AppointmentView(item: item)
                        }
                    }
            }.headerProminence(.increased)
        }
    }
}

//struct HomeView_Previews: PreviewProvider {
//    static var previews: some View {
//        HomeView(token: ., me: .constant(nil))
//    }
//}
