//
//  HomeView.swift
//  Rooster voor Zermelo
//
//  Created by Wisse Hes on 04/09/2022.
//

import SwiftUI
import Alamofire
import FirebaseAnalytics

struct ReverseLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.title
            configuration.icon
        }
    }
}

struct HomeView: View {
    
    @EnvironmentObject var authManager: AuthManager
    
    @StateObject var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationStack {
            todayView
                .navigationTitle("home.home")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            aboutThisApp
                            settings
                        } label: {
                            Label("Menu", systemImage: "gear")
                        }

                    }
                    
                    ToolbarItem(placement: .bottomBar) {
                        HStack {
                            Button("word.today") { viewModel.selectedDate = Date() }
                                .disabled(viewModel.todaySelected)
                            
                            Spacer()
                            
                            DatePicker("word.date", selection: $viewModel.selectedDate, displayedComponents: [.date])
                                .labelsHidden()
                        }
                    }
                }
                .navigationDestination(for: ZermeloLivescheduleAppointment.self) { appointment in
                    AppointmentView(item: appointment)
                }.task {
                    await viewModel.load()
                }.refreshable {
                    await viewModel.reload()
                }.onChange(of: viewModel.selectedDate) { newValue in
                    Task {
                        await viewModel.dateChanged(newValue)
                    }
                }.contentTransition(.opacity)
                .analyticsScreen(name: "Home")
        }
    }
    
    @ViewBuilder
    var todayView: some View {
        if viewModel.isLoading {
            //        if true {
            ProgressView()
                .padding()
        } else {
            GeometryReader { geo in
                List {
                    Section {
                        switch viewModel.scheduleResult {
                        case .success(_):
                            if viewModel.todayAppointments.isEmpty {
                                
                                noAppointmentsFound
                                    .listRowInsets(.none)
                                    .listRowBackground(Color.clear)
                                    .frame(height: geo.size.height / 1.5)
                            } else {
                                DayView(appointments: viewModel.todayAppointments)
                            }
                        case .failure(let error):
                            errorView(error: error)
                                .listRowInsets(.none)
                                .listRowBackground(Color.clear)
                                .frame(height: geo.size.height / 1.5)
                        case .none:
                            ProgressView()
                        }
                    } header: {
                        Text(viewModel.navTitle)
                    }.headerProminence(.increased)
                }
            }
        }
    }
    
    var noAppointmentsFound: some View {
        HStack(alignment: .center) {
            Spacer()
            
            VStack(alignment: .center) {
                Image(systemName: "calendar.badge.exclamationmark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 75, height: 75, alignment: .center)
                    .foregroundColor(.secondary)
                
                Text("home.noAppointmentsFound")
                    .font(.title)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
    }
    
    func errorView(error: AFError) -> some View {
        HStack(alignment: .center) {
            Spacer()
            
            VStack(alignment: .center) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 75, height: 75, alignment: .center)
                    .foregroundColor(.secondary)
                
                Text(error.localizedDescription)
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
    }
    
    var aboutThisApp: some View {
        NavigationLink {
            AboutView()
        } label: {
            Label("about.about", systemImage: "info.circle")
        }
    }
    var settings: some View {
        NavigationLink {
            SettingsView()
        } label: {
            Label("settings.settings", systemImage: "gear")
        }
    }
//    var compare: some View {
//        NavigationLink {
//            CompareView()
//        } label: {
//            Label("Compare", systemImage: "gear")
//        }
//    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(AuthManager())
    }
}
