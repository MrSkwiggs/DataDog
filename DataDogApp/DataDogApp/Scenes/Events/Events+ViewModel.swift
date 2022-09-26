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
        
        @Published
        var showsNominalEvents: Bool = false
        
        init(eventProvider: EventProvider) {
            self.eventProvider = eventProvider
            self.events = filteredEvents(showNominalEvents: showsNominalEvents)
            
            setupSubscriptions()
        }
        
        private func setupSubscriptions() {
            eventProvider
                .publisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    guard let self else { return }
                    self.events = self.filteredEvents(showNominalEvents: self.showsNominalEvents)
                }
                .store(in: &subscriptions)
            
            $showsNominalEvents
                .sink { newValue in
                    self.events = self.filteredEvents(showNominalEvents: newValue)
                }
                .store(in: &subscriptions)
        }
        
        private func filteredEvents(showNominalEvents: Bool) -> [MetricThresholdEvent] {
            eventProvider
                .events
                .filter { event in
                    showNominalEvents ? true : event.state.isExceeding
                }
                .reversed()
        }
    }
}
