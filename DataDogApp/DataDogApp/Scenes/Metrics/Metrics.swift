//
//  Metrics.swift
//  DataDogWatchApp
//
//  Created by Dorian Grolaux on 20/09/2022.
//

import SwiftUI

struct Metrics: View {
    
    let gradient = Gradient(colors: [.green, .orange, .red])

    @StateObject
    var viewModel: ViewModel
    
    fileprivate func gauge(value: Float, title: String) -> some View {
        return Gauge(value: value, label: {
            Text(title)
        }, currentValueLabel: {
            Text("\(value * 100, specifier: "%.1f")%")
        })
        .gaugeStyle(.accessoryCircular)
        .tint(gradient)
    }
    
    var body: some View {
        List {
            Group {
                HStack {
                    gauge(value: viewModel.cpuLoad, title: "CPU")
                        .animation(.default, value: viewModel.cpuLoad)
                    Text(viewModel.cpuLoadExceededThreshold ? "Exceeded" : "Nominal")
                }
                gauge(value: viewModel.memoryLoad, title: "MEM")
                    .animation(.default, value: viewModel.memoryLoad)
                gauge(value: viewModel.batteryState, title: "BATT")
                    .animation(.default, value: viewModel.batteryState)
            }
            .padding()
        }
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
