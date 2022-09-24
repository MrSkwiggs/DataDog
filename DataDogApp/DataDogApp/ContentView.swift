//
//  ContentView.swift
//  DataDogWatchApp
//
//  Created by Dorian Grolaux on 20/09/2022.
//

import SwiftUI
import Watcher
import SFSafeSymbols

struct ContentView: View {
    
    static let watcher: Watcher =
        .configure(cpuThreshold: 0.25,
                   memoryLoadThreshold: 0.5,
                   refreshFrequency: 1)
    
    let metricsViewModel: Metrics.ViewModel =
        .init(cpuLoadProvider: ContentView.watcher.cpuLoad,
              memoryLoadProvider: ContentView.watcher.memoryLoad,
              batteryStateProvider: Mock.MetricConfigurator().metricManager)
    
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
