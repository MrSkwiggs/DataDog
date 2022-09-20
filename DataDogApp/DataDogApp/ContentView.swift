//
//  ContentView.swift
//  DataDogWatchApp
//
//  Created by Dorian Grolaux on 20/09/2022.
//

import SwiftUI
import SFSafeSymbols

struct ContentView: View {
    var body: some View {
        TabView {
            Metrics(viewModel: .init(cpuLoadProvider: Mock.CPULoadProvider()))
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
