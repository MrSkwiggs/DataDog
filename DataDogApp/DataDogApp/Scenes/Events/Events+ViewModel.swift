//
//  Events+ViewModel.swift
//  DataDogApp
//
//  Created by Dorian Grolaux on 24/09/2022.
//

import Foundation
import Combine
import Watcher

extension Events {
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
                .thresholdEventPublisher
                .receive(on: DispatchQueue.main)
                .map { [weak] thresholdState in
                    
                }
                .store(in: &subscriptions)
            
            memoryLoadProvider
                .thresholdEventPublisher
                .receive(on: DispatchQueue.main)
                .assign(to: \.memoryLoad, on: self)
                .store(in: &subscriptions)
            
            batteryStateProvider
                .thresholdEventPublisher
                .receive(on: DispatchQueue.main)
                .assign(to: \.batteryState, on: self)
                .store(in: &subscriptions)
        }
        
        private func thresholdStateToEvent(_ thresholdState: MetricThresholdState, for metric: Event.Metric) -> Event {
            switch thresholdState {
            case .nominal:
                return .ini
            case .exceeded:
                <#code#>
            }
        }
        
        @Published
        var events: [Event] = []
    }
}
