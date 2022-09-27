//
//  RootView+ViewModel.swift
//  DataDogApp
//
//  Created by Dorian Grolaux on 25/09/2022.
//

import Foundation
import Combine
import Watcher

extension RootView {
    class ViewModel: ObservableObject {
        private var subscriptions: [AnyCancellable] = []
        private var eventProvider: EventProvider
        private var notificationManager: NotificationManagerUseCase
        
        init(eventProvider: EventProvider, notificationManager: NotificationManagerUseCase) {
            self.eventProvider = eventProvider
            self.notificationManager = notificationManager
            
            setupSubscriptions()
        }
        
        private func setupSubscriptions() {
            eventProvider
                .publisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    guard let self else { return }
                    guard self.selectedTab != .events else { return }
                    self.newEventsCount += 1
                }
                .store(in: &subscriptions)
            
            notificationManager
                .
            
            $selectedTab
                .removeDuplicates()
                .sink { [self] tab in
                    switch tab {
                    case .metrics: break
                    case .events:
                        notificationManager.clearBadgeCount()
                    }
                }
                .store(in: &subscriptions)
        }
        
        @Published
        var newEventsCount: Int = 0
        
        @Published
        var selectedTab: Tab = .metrics
    }
}

extension RootView.ViewModel {
    enum Tab: Int {
        case metrics, events
    }
}
