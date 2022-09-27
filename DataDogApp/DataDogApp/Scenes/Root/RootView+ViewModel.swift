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
        private var appManager: AppManagerUseCase
        
        init(appManager: AppManagerUseCase) {
            self.appManager = appManager
            
            setupSubscriptions()
        }
        
        private func setupSubscriptions() {
            appManager
                .unseenEventsNumberPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] count in
                    guard let self else { return }
                    guard self.selectedTab != .events else {
                        self.appManager.markAllEventsAsSeen()
                        self.newEventsCount = 0
                        return
                    }
                    self.newEventsCount = count
                }
                .store(in: &subscriptions)
            
            $selectedTab
                .removeDuplicates()
                .sink { tab in
                    switch tab {
                    case .metrics: break
                    case .events:
                        self.appManager.markAllEventsAsSeen()
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
