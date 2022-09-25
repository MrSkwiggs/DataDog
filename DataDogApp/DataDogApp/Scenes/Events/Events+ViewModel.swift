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
        private let eventProvider: EventProvider
        private var subscriptions: [AnyCancellable] = []
        
        @Published
        var events: [MetricThresholdEvent] = []
        
        init(eventProvider: EventProvider) {
            self.eventProvider = eventProvider
            
            setupSubscriptions()
        }
        
        private func setupSubscriptions() {
            eventProvider
                .publisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] event in
                    self?.events.append(event)
                }
                .store(in: &subscriptions)
        }
    }
}
