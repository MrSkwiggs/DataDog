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
        private let appManager: AppManagerUseCase
        private var subscriptions: [AnyCancellable] = []
        
        @Published
        var events: [MetricThresholdEvent] = []
        
        @Published
        var showsNominalEvents: Bool = false
        
        init(appManager: AppManagerUseCase) {
            self.appManager = appManager
            
            setupSubscriptions()
        }
        
        private func setupSubscriptions() {
            appManager
                .eventsPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] events in
                    guard let self else { return }
                    self.events = events
                }
                .store(in: &subscriptions)
            
            $showsNominalEvents
                .sink { newValue in
                    self.appManager.setShouldReportNominalEventsToo(newValue)
                }
                .store(in: &subscriptions)
        }
    }
}
