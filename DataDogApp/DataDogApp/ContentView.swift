//
//  ContentView.swift
//  DataDogWatchApp
//
//  Created by Dorian Grolaux on 20/09/2022.
//

import SwiftUI
import SFSafeSymbols

struct ContentView: View {
    
    let metricsViewModel: Metrics.ViewModel =
        .init(cpuLoadProvider: Mock.CPULoadProvider(),
              memoryLoadProvider: Mock.CPULoadProvider(refreshFrequency: 3),
              batteryStateProvider: Mock.CPULoadProvider(refreshFrequency: 5))
    
    var body: some View {
        TabView {
            Metrics(viewModel: metricsViewModel)
                .tabItem {
                    Image(systemSymbol: .gaugeMedium)
                }
            Events()
                .badge(2)
                .tabItem {
                    Image(systemSymbol: .listDash)
                }
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
