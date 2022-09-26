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
        
        private let cpuLoadProvider: MetricWrapper
        private let memoryLoadProvider: MetricWrapper
        private let batteryLevelProvider: MetricWrapper
        
        private var subscriptions: [AnyCancellable] = []
        
        init(cpuLoadProvider: any MetricManagerConfiguratorUseCase,
             memoryLoadProvider: any MetricManagerConfiguratorUseCase,
             batteryLevelProvider: any MetricManagerConfiguratorUseCase) {
            self.cpuLoadProvider = .init(configurator: cpuLoadProvider)
            self.memoryLoadProvider = .init(configurator: memoryLoadProvider)
            self.batteryLevelProvider = .init(configurator: batteryLevelProvider)
            
            setupSubscriptions()
        }
        
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

extension Metrics.ViewModel {
    class MetricWrapper: ObservableObject {
        
        private let configurator: any MetricManagerConfiguratorUseCase
        private var subscriptions: [AnyCancellable]
        
        init(configurator: any MetricManagerConfiguratorUseCase) {
            self.configurator = configurator
            
            setupSubscriptions()
        }
        
        private func setupSubscriptions() {
            configurator
                .metricManager
                .percentagePublisher
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { [weak self] value in
                    self?.metricPercentage = value
                    self?.metricHistory.append(value)
                })
                .store(in: &subscriptions)
            
            configurator
                .metricManager
                .thresholdPublisher
                .receive(on: DispatchQueue.main)
                .assign(to: \.metricThreshold, on: self)
                .store(in: &subscriptions)
            
            configurator
                .metricManager
                .thresholdStatePublisher
                .receive(on: DispatchQueue.main)
                .map(\.isExceeding)
                .assign(to: \.metricExceededThreshold, on: self)
                .store(in: &subscriptions)
        }
        
        @Published
        var metricPercentage: Float = 0
        
        @Published
        var metricThreshold: Float = 0.25
        
        @Published
        var metricExceededThreshold: Bool = false
        
        @Published
        var metricHistory: FixedSizeCollection<Float> = .init(repeating: 0, count: 30)
        
        func set(threshold: Float) {
            configurator.set(threshold: threshold, range: configurator.metricManager.range)
        }
    }
}
