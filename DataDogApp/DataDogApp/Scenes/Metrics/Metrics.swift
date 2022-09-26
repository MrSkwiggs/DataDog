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
        
        LazyVGrid(columns: [GridItem(.fixed(200)), GridItem(.fixed(200))]) {
            
            cpuMetric
                .onTapGesture {
                    viewModel.userDidTapMetric(.cpu)
                }
            
            memoryMetric
            
            batteryMetric
        }
        .sheet(item: $viewModel.metricTypeThresholdEditor, content: { metric in
            ThresholdEditor(threshold: $viewModel.cpuLoadThreshold,
                                  metricType: metric) {
                viewModel.userDidFinishEditingThreshold()
            }
                                  .presentationDetents([.medium])
        })
        .navigationTitle("Metrics")
    }
    
    private var cpuMetric: some View {
        Metric(title: MetricType.cpu.description,
               gaugeName: MetricType.cpu.rawValue,
               value: viewModel.cpuLoad,
               threshold: viewModel.cpuLoadThreshold,
               isExceedingThreshold: viewModel.cpuLoadExceededThreshold,
               history: viewModel.cpuLoadHistory)
    }
    
    private var memoryMetric: some View {
        Metric(title: MetricType.memory.description,
               gaugeName: MetricType.memory.rawValue,
               value: viewModel.memoryLoad,
               threshold: viewModel.memoryLoadThreshold,
               isExceedingThreshold: viewModel.memoryLoadExceededThreshold,
               history: viewModel.memoryLoadHistory)
    }
    
    private var batteryMetric: some View {
        Metric(title: MetricType.battery.description,
               gaugeName: MetricType.battery.rawValue,
               value: viewModel.batteryLevel,
               threshold: viewModel.batteryLevelThreshold,
               isExceedingThreshold: viewModel.batteryLevelExceededThreshold,
               history: viewModel.batteryLevelHistory,
               isRangeInversed: true)
    }
}

struct Metrics_Previews: PreviewProvider {
    
    static let cpuLoadConfigurator = Mock.MetricConfigurator()
    static let memoryLoadConfigurator = Mock.MetricConfigurator()
    static let batteryLevel = Mock.MetricConfigurator()
    
    static let metricsViewModel: Metrics.ViewModel =
        .init(cpuLoadProvider: cpuLoadConfigurator.metricManager,
              memoryLoadProvider: memoryLoadConfigurator.metricManager,
              batteryLevelProvider: batteryLevel.metricManager)
    static var previews: some View {
        Metrics(viewModel: metricsViewModel)
    }
}
