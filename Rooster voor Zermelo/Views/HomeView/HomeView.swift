//
//  HomeView.swift
//  Rooster voor Zermelo
//
//  Created by Wisse Hes on 04/09/2022.
//

import SwiftUI
import Alamofire

struct ReverseLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.title
            configuration.icon
        }
    }
}

struct HomeView: View {    
    // Only use `didSet` on `me` because it is the last
    // thing set, after the token.
    
    @EnvironmentObject var authManager: AuthManager
    
    @StateObject var viewModel = HomeViewModel()
    
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
                    
                    ToolbarItem(placement: .bottomBar) {
                        HStack {
                            Button("Vandaag") { viewModel.selectedDate = Date() }
                                .disabled(viewModel.todaySelected)
                            
                            Spacer()
                            
                            DatePicker("Datum", selection: $viewModel.selectedDate, displayedComponents: [.date])
                                .labelsHidden()
                        }
                    }
                }
                .navigationDestination(for: ZermeloLivescheduleAppointment.self) { appointment in
                    AppointmentView(item: appointment)
                }
        }.task {
            guard let me = authManager.me else { return }
            await viewModel.load(me: me)
        }.refreshable {
            await viewModel.reload()
        }.onChange(of: viewModel.selectedDate) { newValue in
            Task {
                await viewModel.reload()
            }
        }
    }
    
    @ViewBuilder
    var todayView: some View {
        if viewModel.isLoading {
            ProgressView().padding()
        } else if viewModel.todayAppointments.isEmpty {
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
                Section {
                    DayView(appointments: viewModel.todayAppointments)
                } header: {
                    Text("\(viewModel.selectedDate, style: .date) \(viewModel.todaySelected ? "(Vandaag)" : "")")
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
