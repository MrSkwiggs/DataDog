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
        
        private let cpuLoadProvider: MetricManager
        private let memoryLoadProvider: MetricManager
        private let batteryStateProvider: MetricManager
        
        private var subscriptions: [AnyCancellable] = []
        
        init(cpuLoadProvider: MetricManager,
             memoryLoadProvider: MetricManager,
             batteryStateProvider: MetricManager) {
            self.cpuLoadProvider = cpuLoadProvider
            self.memoryLoadProvider = memoryLoadProvider
            self.batteryStateProvider = batteryStateProvider
            
            setupSubscriptions()
        }
        
        private func setupSubscriptions() {
            
            // Generally, we should avoid using `assign(to: _, on: _)`
            // as it creates a strong retain cycle.
            // However, in the case of `@Published` values, Swift handles this for us
            // and makes it memory-safe.
            
            cpuLoadProvider
                .percentagePublisher
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { [weak self] value in
                    self?.cpuLoad = value
                    self?.cpuLoadHistory.append(value)
                })
                .store(in: &subscriptions)
            
            cpuLoadProvider
                .thresholdPublisher
                .receive(on: DispatchQueue.main)
                .assign(to: \.cpuLoadThreshold, on: self)
                .store(in: &subscriptions)
            
            cpuLoadProvider
                .thresholdStatePublisher
                .receive(on: DispatchQueue.main)
                .map(\.isExceeding)
                .assign(to: \.cpuLoadExceededThreshold, on: self)
                .store(in: &subscriptions)
            
            memoryLoadProvider
                .percentagePublisher
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
        var cpuLoadThreshold: Float = 0.25
        
        @Published
        var cpuLoadExceededThreshold: Bool = false
        
        @Published
        var cpuLoadHistory: FixedSizeCollection<Float> = .init(repeating: 0, count: 30)
        
        @Published
        var memoryLoad: Float = 0
        
        @Published
        var batteryState: Float = 0
    }
}
