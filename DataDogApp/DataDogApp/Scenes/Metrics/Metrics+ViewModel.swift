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
        private let batteryLevelProvider: MetricManager
        
        private var subscriptions: [AnyCancellable] = []
        
        init(cpuLoadProvider: MetricManager,
             memoryLoadProvider: MetricManager,
             batteryLevelProvider: MetricManager) {
            self.cpuLoadProvider = cpuLoadProvider
            self.memoryLoadProvider = memoryLoadProvider
            self.batteryLevelProvider = batteryLevelProvider
            
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
                .sink(receiveValue: { [weak self] value in
                    self?.memoryLoad = value
                    self?.memoryLoadHistory.append(value)
                })
                .store(in: &subscriptions)
            
            memoryLoadProvider
                .thresholdPublisher
                .receive(on: DispatchQueue.main)
                .assign(to: \.memoryLoadThreshold, on: self)
                .store(in: &subscriptions)
            
            memoryLoadProvider
                .thresholdStatePublisher
                .receive(on: DispatchQueue.main)
                .map(\.isExceeding)
                .assign(to: \.memoryLoadExceededThreshold, on: self)
                .store(in: &subscriptions)
            
            batteryLevelProvider
                .percentagePublisher
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { [weak self] value in
                    self?.batteryLevel = value
                    self?.batteryLevelHistory.append(value)
                })
                .store(in: &subscriptions)
            
            batteryLevelProvider
                .thresholdPublisher
                .receive(on: DispatchQueue.main)
                .assign(to: \.batteryLevelThreshold, on: self)
                .store(in: &subscriptions)
            
            batteryLevelProvider
                .thresholdStatePublisher
                .receive(on: DispatchQueue.main)
                .map(\.isExceeding)
                .assign(to: \.batteryLevelExceededThreshold, on: self)
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
        var memoryLoadThreshold: Float = 0.25
        
        @Published
        var memoryLoadExceededThreshold: Bool = false
        
        @Published
        var memoryLoadHistory: FixedSizeCollection<Float> = .init(repeating: 0, count: 30)
        
        @Published
        var batteryLevel: Float = 0
        
        @Published
        var batteryLevelThreshold: Float = 0.25
        
        @Published
        var batteryLevelExceededThreshold: Bool = false
        
        @Published
        var batteryLevelHistory: FixedSizeCollection<Float> = .init(repeating: 0, count: 30)
        
        @Published
        var metricTypeThresholdEditor: MetricType?
        
        func userDidTapMetric(_ metric: MetricType) {
            self.metricTypeThresholdEditor = metric
        }
        
        func userDidFinishEditingThreshold() {
            self.metricTypeThresholdEditor = nil
        }
    }
}
