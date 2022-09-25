//
//  Metrics.swift
//  DataDogWatchApp
//
//  Created by Dorian Grolaux on 20/09/2022.
//

import SwiftUI
import Watcher

struct Metrics: View {
    
    

    @StateObject
    var viewModel: ViewModel
    
    var body: some View {
        
        Grid {
            GridRow {
                Metric(title: MetricType.cpu.description,
                       gaugeName: MetricType.cpu.rawValue,
                       value: viewModel.cpuLoad,
                       threshold: viewModel.cpuLoadThreshold,
                       isExceedingThreshold: viewModel.cpuLoadExceededThreshold,
                       history: viewModel.cpuLoadHistory)
            }
//            GridRow {
//                Gauge(title: "CPU", value: viewModel.cpuLoad)
//                Gauge
//            }
        }
//        List {
//            Group {
//                HStack {
//                    gauge(value: viewModel.cpuLoad, title: "CPU")
//                        .animation(.default, value: viewModel.cpuLoad)
//                    Text(viewModel.cpuLoadExceededThreshold ? "Exceeded" : "Nominal")
//                }
//                gauge(value: viewModel.memoryLoad, title: "MEM")
//                    .animation(.default, value: viewModel.memoryLoad)
//                gauge(value: viewModel.batteryState, title: "BATT")
//                    .animation(.default, value: viewModel.batteryState)
//            }
//            .padding()
//        }
        .navigationTitle("Metrics")
    }
}

struct Metrics_Previews: PreviewProvider {
    
    static let cpuLoadConfigurator = Mock.MetricConfigurator()
    static let memoryLoadConfigurator = Mock.MetricConfigurator()
    static let batteryState = Mock.MetricConfigurator()
    
    static let metricsViewModel: Metrics.ViewModel =
        .init(cpuLoadProvider: cpuLoadConfigurator.metricManager,
              memoryLoadProvider: memoryLoadConfigurator.metricManager,
              batteryStateProvider: batteryState.metricManager)
    static var previews: some View {
        Metrics(viewModel: metricsViewModel)
    }
}
