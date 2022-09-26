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
    
    @StateObject
    private var cpuLoad: ViewModel.MetricWrapper
    
    @StateObject
    private var memoryLoad: ViewModel.MetricWrapper
    
    @StateObject
    private var batteryLevel: ViewModel.MetricWrapper
    
    init(viewModel: ViewModel) {
        self._viewModel = .init(wrappedValue: viewModel)
        self._cpuLoad = .init(wrappedValue: viewModel.cpuLoad)
        self._memoryLoad = .init(wrappedValue: viewModel.memoryLoad)
        self._batteryLevel = .init(wrappedValue: viewModel.batteryLevel)
    }
    
    var body: some View {
        
        LazyVGrid(columns: [GridItem(.fixed(200)), GridItem(.fixed(200))]) {
            
            cpuMetric
                .onTapGesture {
                    viewModel.userDidTapMetric(.cpu)
                }
            
            memoryMetric
                .onTapGesture {
                    viewModel.userDidTapMetric(.memory)
                }
            
            batteryMetric
                .onTapGesture {
                    viewModel.userDidTapMetric(.battery)
                }
        }
        .sheet(item: $viewModel.editorWrapper, content: { editor in
            ThresholdEditor(threshold: .init(get: editor.get, set: editor.set),
                            metricType: editor.metricType) {
                viewModel.userDidFinishEditingThreshold()
            }
                                  .presentationDetents([.medium])
        })
        .navigationTitle("Metrics")
    }
    
    private var cpuMetric: some View {
        Metric(title: MetricType.cpu.description,
               gaugeName: MetricType.cpu.rawValue,
               value: viewModel.cpuLoad.metricPercentage,
               threshold: viewModel.cpuLoad.metricThreshold,
               isExceedingThreshold: viewModel.cpuLoad.metricExceededThreshold,
               history: viewModel.cpuLoad.metricHistory)
    }
    
    private var memoryMetric: some View {
        Metric(title: MetricType.memory.description,
               gaugeName: MetricType.memory.rawValue,
               value: viewModel.memoryLoad.metricPercentage,
               threshold: viewModel.memoryLoad.metricThreshold,
               isExceedingThreshold: viewModel.memoryLoad.metricExceededThreshold,
               history: viewModel.memoryLoad.metricHistory)
    }
    
    private var batteryMetric: some View {
        Metric(title: MetricType.battery.description,
               gaugeName: MetricType.battery.rawValue,
               value: viewModel.batteryLevel.metricPercentage,
               threshold: viewModel.batteryLevel.metricThreshold,
               isExceedingThreshold: viewModel.batteryLevel.metricExceededThreshold,
               history: viewModel.batteryLevel.metricHistory,
               isRangeInversed: true)
    }
}

struct Metrics_Previews: PreviewProvider {
    
    static let cpuLoadManager = Mock.metricManager()
    static let memoryLoadManager = Mock.metricManager()
    static let batteryLevelManager = Mock.metricManager()
    
    static let metricsViewModel: Metrics.ViewModel =
        .init(cpuLoadManager: cpuLoadManager,
              memoryLoadManager: memoryLoadManager,
              batteryLevelManager: batteryLevelManager)
    static var previews: some View {
        Metrics(viewModel: metricsViewModel)
    }
}
