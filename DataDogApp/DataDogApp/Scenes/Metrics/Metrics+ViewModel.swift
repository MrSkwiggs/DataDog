//
//  MetricsViewModel.swift
//  DataDogWatchApp
//
//  Created by Dorian Grolaux on 20/09/2022.
//

import Foundation
import Combine

extension Metrics {
    class ViewModel: ObservableObject {
        private let cpuLoadProvider: CPULoadProvider
        
        private var subscriptions: [AnyCancellable] = []
        
        init(cpuLoadProvider: CPULoadProvider) {
            self.cpuLoadProvider = cpuLoadProvider
            
            setupSubscriptions()
        }
        
        private func setupSubscriptions() {
            cpuLoadProvider
                .cpuLoadPublisher
                .receive(on: DispatchQueue.main)
                .assign(to: \.cpuLoad, on: self)
                .store(in: &subscriptions)
        }
        
        @Published
        var cpuLoad: Double = 0
    }
}
