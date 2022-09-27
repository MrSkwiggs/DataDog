//
//  RootView.swift
//  DataDogWatchApp
//
//  Created by Dorian Grolaux on 20/09/2022.
//

import SwiftUI
import Watcher
import SFSafeSymbols

struct RootView: View {
    
    @EnvironmentObject
    var viewModelProvider: ViewModelProvider
    
    @StateObject
    var viewModel: ViewModel
    
    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            NavigationView {
                Metrics(viewModel: viewModelProvider.metricsViewModel)
            }
            .tabItem {
                Image(systemSymbol: .gaugeMedium)
            }
            .tag(ViewModel.Tab.metrics)
            
            NavigationView {
                Events(viewModel: viewModelProvider.eventsViewModel)
            }
            .badge(viewModel.newEventsCount)
            .tabItem {
                Image(systemSymbol: .listDash)
            }
            .tag(ViewModel.Tab.events)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    
    static let viewModelProvider: ViewModelProvider = .init(watcher: .configure(),
                                                            notificationManager: Mock.NotificationManager(),
                                                            appManager: Mock.AppManager())
    
    static var previews: some View {
        RootView(viewModel: viewModelProvider.rootViewModel)
            .environmentObject(viewModelProvider)
    }
}
