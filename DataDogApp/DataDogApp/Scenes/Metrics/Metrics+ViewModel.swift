//
//  MetricsViewModel.swift
//  DataDogWatchApp
//
//  Created by Dorian Grolaux on 20/09/2022.
//

import Foundation
import Combine
import UserNotifications
import Watcher

extension Metrics {
    class ViewModel: ObservableObject {
        
        private var subscriptions: [AnyCancellable] = []
        private let notificationManager: NotificationManagerUseCase
        
        // Convenience local var because getting this status is otherwise async
        private var notificationAuthorizationStatus: UNAuthorizationStatus = .notDetermined
        
        init(cpuLoadManager: any MetricManagerUseCase,
             memoryLoadManager: any MetricManagerUseCase,
             batteryLevelManager: any MetricManagerUseCase,
             notificationManager: NotificationManagerUseCase) {
            self.cpuLoad = .init(manager: cpuLoadManager)
            self.memoryLoad = .init(manager: memoryLoadManager)
            self.batteryLevel = .init(manager: batteryLevelManager)
            self.notificationManager = notificationManager
            
            setupSubscriptions()
        }
        
        private func setupSubscriptions() {
            notificationManager
                .isNotificationSchedulingAllowedPublisher
                .assign(to: \.notificationsEnabled, on: self)
                .store(in: &subscriptions)
        }
        
        @Published
        var notificationsEnabled: Bool = false
        
        @Published
        var cpuLoad: MetricWrapper
        @Published
        var memoryLoad: MetricWrapper
        @Published
        var batteryLevel: MetricWrapper
        
        @Published
        var editorWrapper: EditorWrapper?
        
        var openSystemSettings: PassthroughSubject<Void, Never> = .init()
        
        func userDidSetNotifications(enabled: Bool) {
            if enabled && notificationManager.authorizationStatus == .denied {
                openSystemSettings.send()
                return
            }
            enabled
                ? notificationManager.enableNotificationScheduling()
                : notificationManager.disableNotificationScheduling()
        }
        
        func userDidTapMetric(_ metric: MetricType) {
            let wrapper: MetricWrapper
            switch metric {
            case .cpu:
                wrapper = cpuLoad
            case .memory:
                wrapper = memoryLoad
            case .battery:
                wrapper = batteryLevel
            }
            self.editorWrapper = .init(metricType: metric, get: {
                wrapper.metricThreshold
            }, set: { value in
                wrapper.set(threshold: value)
            })
        }
        
        func userDidFinishEditingThreshold() {
            self.editorWrapper = nil
        }
        
        func viewDidAppear() {
            notificationManager.fetchAuthorizationStatus()
        }
    }
}

extension Metrics.ViewModel {
    class MetricWrapper: ObservableObject {
        
        private let manager: any MetricManagerUseCase
        private var subscriptions: [AnyCancellable] = []
        
        init(manager: any MetricManagerUseCase) {
            self.manager = manager
            
            setupSubscriptions()
        }
        
        private func setupSubscriptions() {
            manager
                .percentagePublisher
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { [weak self] value in
                    self?.metricPercentage = value
                    self?.metricHistory.append(value)
                })
                .store(in: &subscriptions)
            
            manager
                .thresholdPublisher
                .receive(on: DispatchQueue.main)
                .assign(to: \.metricThreshold, on: self)
                .store(in: &subscriptions)
            
            manager
                .thresholdStatePublisher
                .receive(on: DispatchQueue.main)
                .map(\.isCritical)
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
            manager.threshold = threshold
        }
    }
}

extension Metrics.ViewModel {
    struct EditorWrapper: Identifiable {
        let id: String = UUID().uuidString
        let metricType: MetricType
        let get: () -> Float
        let set: (Float) -> Void
    }
}
