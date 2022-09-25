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
    
    let watcher: Watcher
    
    var body: some View {
        TabView {
            Metrics(viewModel: .init(cpuLoadProvider: watcher.cpuLoad,
                                     memoryLoadProvider: watcher.memoryLoad,
                                     batteryStateProvider: watcher.batteryLevel))
                .tabItem {
                    Image(systemSymbol: .gaugeMedium)
                }
            Events(viewModel: .init(eventProvider:  watcher.eventProvider))
                .badge(2)
                .tabItem {
                    Image(systemSymbol: .listDash)
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(watcher: .configure())
    }
}
