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
        private var unseenEventNumberSubscriber: AnyCancellable?
        private var appManager: AppManagerUseCase
        
        init(appManager: AppManagerUseCase) {
            self.appManager = appManager
            
            setupSubscriptions()
        }
        
        private func setupSubscriptions() {
            unseenEventNumberSubscriber = getUnseenEventsNumberSubscriber()
            
            $selectedTab
                .removeDuplicates()
                .sink { tab in
                    switch tab {
                    case .metrics:
                        self.unseenEventNumberSubscriber = self.getUnseenEventsNumberSubscriber()
                    case .events:
                        self.unseenEventNumberSubscriber?.cancel()
                        self.appManager.markAllEventsAsSeen()
                    }
                }
                .store(in: &subscriptions)
        }
        
        private func getUnseenEventsNumberSubscriber() -> AnyCancellable {
            appManager
                .unseenEventsNumberPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] count in
                    guard let self else { return }
                    self.newEventsCount = count
                }
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
