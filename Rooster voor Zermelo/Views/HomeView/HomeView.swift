//
//  HomeView.swift
//  Rooster voor Zermelo
//
//  Created by Wisse Hes on 04/09/2022.
//

import SwiftUI
import Alamofire
import FirebaseAnalytics

struct HomeView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var actionService: ActionService
    @Environment(\.scenePhase) var scenePhase
    @StateObject var viewModel = HomeViewModel()
    
    func checkForAction() {
        
        guard let action = actionService.action else { return }
        defer { actionService.action = nil }
        switch action {
        case .todayAction:
            viewModel.selectedDate = .now
        case .tomorrowAction:
            viewModel.selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .now
        default: break;
        }
    }
    
    var body: some View {
        NavigationStack {
            todayView
                .navigationTitle("home.home")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            aboutThisApp
                            settings
                            if viewModel.users.count > 1 {
                                userPicker
                            }
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
                    viewModel.reloadUsers()
                    await viewModel.load()
                }.refreshable {
                    await viewModel.reload()
                }.onChange(of: viewModel.selectedDate) { newValue in
                    Task {
                        await viewModel.dateChanged(newValue)
                    }
                }
                .onChange(of: scenePhase) { newValue in
                    switch newValue {
                    case .active:
                        checkForAction()
                    default: break;
                    }
                }
                .contentTransition(.opacity)
                .analyticsScreen(name: "Home")
                .gesture(
                    DragGesture()
                        .onEnded(viewModel.hanldeGestureEnd(_:))
                )
        }
    }

    var todayView: some View {
        GeometryReader { geo in
            List {
                Section {
                    switch viewModel.scheduleResult {
                    case .success(_):
                        if viewModel.isLoading {
                          loadingView
                                .listRowInsets(.none)
                                .listRowBackground(Color.clear)
                                .frame(height: geo.size.height / 1.5)
                        } else if viewModel.todayAppointments.isEmpty {
                            
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
                        loadingView
                            .listRowInsets(.none)
                            .listRowBackground(Color.clear)
                            .frame(height: geo.size.height / 1.5)
                    }
                } header: {
                    Text(viewModel.navTitle)
                }.headerProminence(.increased)
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
    
    var loadingView: some View {
        HStack(alignment: .center) {
            Spacer()
            
            VStack(alignment: .center) {
                ProgressView()
                    .controlSize(.large)
                
                Text("word.loading")
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
    
    var userPicker: some View {
        Picker(selection: $viewModel.currentUser) {
            ForEach(viewModel.users, id: \.id) { user in
                Text(user.name)
                    .tag(user as User?)
            }
        } label: {
            Label("settings.users", systemImage: "person.2")
        }.pickerStyle(.menu)
            .onChange(of: viewModel.currentUser) { newValue in
                Task {
                    viewModel.updateUsers()
                    await viewModel.load(animation: true)
                }
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
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(AuthManager())
            .environmentObject(ActionService())
    }
}
