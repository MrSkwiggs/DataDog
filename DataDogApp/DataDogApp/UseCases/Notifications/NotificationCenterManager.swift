//
//  NotificationCenterManager.swift
//  DataDogApp
//
//  Created by Dorian Grolaux on 27/09/2022.
//

import Foundation
import Combine
import UserNotifications
import Watcher

class NotificationManager: NotificationManagerUseCase {
    
    // MARK: - Private
    
    private let center: UNUserNotificationCenter = .current()
    private let percentageNumberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        return formatter
    }()
    
    private let authorizationStatusSubject: CurrentValueSubject<UNAuthorizationStatus, Never> = .init(.notDetermined)
    
    private func fetchAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            guard let self else { return }
            self.authorizationStatusSubject.send(settings.authorizationStatus)
        }
    }
    
    private func title(for event: MetricThresholdEvent) -> String {
        event.state.isExceeding
        ? "⚠️ \(event.metricType.description) exceeded"
        : "✅ \(event.metricType.description) nominal"
    }
    
    private func subtitle(for event: MetricThresholdEvent) -> String {
        let metric = event.metricType.rawValue
        let percentage = String(format: "%1.0f", event.state.percentage)
        return "\(metric) crossed the \(percentage)% threshold"
    }
    
    init() {
        fetchAuthorizationStatus()
    }
    
    // MARK: - Protocol Conformance
    
    lazy var authorizationStatusPublisher: AnyPublisher<UNAuthorizationStatus, Never> = {
        authorizationStatusPublisher.eraseToAnyPublisher()
    }()
    
    func requestPermission(_ handler: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization { granted, error in
            guard error == nil else { return }
            handler(granted)
            self.fetchAuthorizationStatus()
        }
    }
    
    func sendNotification(for event: MetricThresholdEvent) throws {
        let content = UNMutableNotificationContent()
        content.title = title(for: event)
        content.subtitle = subtitle(for: event)
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0, repeats: false)
        
        // choose a random identifier
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        // add our notification request
        center.add(request)
    }
}
