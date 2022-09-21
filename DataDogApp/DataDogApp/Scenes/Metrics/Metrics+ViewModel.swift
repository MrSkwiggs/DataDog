//
//  MetricsViewModel.swift
//  DataDogWatchApp
//
//  Created by Dorian Grolaux on 20/09/2022.
//

import Foundation
import Combine
import Watcher

extension Metrics {
    class ViewModel: ObservableObject {
        
        typealias MetricProvider = MetricProviderUseCase
        
        private let cpuLoadProvider: any MetricProvider
        private let memoryLoadProvider: any MetricProvider
        private let batteryStateProvider: any MetricProvider
        
        private var subscriptions: [AnyCancellable] = []
        
        init<CPULoadProvider: MetricProvider,
             MemoryLoadProvider: MetricProvider,
             BatteryStateProvider: MetricProvider>(
                cpuLoadProvider: CPULoadProvider,
                memoryLoadProvider: MemoryLoadProvider,
                batteryStateProvider: BatteryStateProvider) {
                    self.cpuLoadProvider = cpuLoadProvider
                    self.memoryLoadProvider = memoryLoadProvider
                    self.batteryStateProvider = batteryStateProvider
                    
                    setupSubscriptions()
                }
        
        private func setupSubscriptions() {
            cpuLoadProvider
                .publisher
                .receive(on: DispatchQueue.main)
                .assign(to: \.cpuLoad, on: self)
                .store(in: &subscriptions)
            
            memoryLoadProvider
                .publisher
                .receive(on: DispatchQueue.main)
                .assign(to: \.memoryLoad, on: self)
                .store(in: &subscriptions)
            
            batteryStateProvider
                .publisher
                .receive(on: DispatchQueue.main)
                .assign(to: \.batteryState, on: self)
                .store(in: &subscriptions)
        }
        
        @Published
        var cpuLoad: Float = 0
        
        @Published
        var memoryLoad: Float = 0
        
        @Published
        var batteryState: Float = 0
    }
}
