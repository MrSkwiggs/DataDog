//
//  NotificationManager.swift
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
    private var userNotificationPreference: Bool = false
    
    private let authorizationStatusSubject: CurrentValueSubject<UNAuthorizationStatus, Never> = .init(.notDetermined)
    private let isNotificationSchedulingAllowedSubject: CurrentValueSubject<Bool, Never> = .init(false)
    
    private func title(for event: MetricThresholdEvent) -> String {
        event.state.isCritical
        ? "⚠️ \(event.metricType.description) critical"
        : "✅ \(event.metricType.description) nominal"
    }
    
    private func subtitle(for event: MetricThresholdEvent) -> String {
        let metric = event.metricType.rawValue
        let percentage = String(format: "%1.0f", event.state.percentage * 100)
        return "\(metric) at \(percentage)%"
    }
    
    init() {
        fetchAuthorizationStatus()
    }
    
    // MARK: - Protocol Conformance
    
    var authorizationStatus: UNAuthorizationStatus  { authorizationStatusSubject.value }
    lazy var authorizationStatusPublisher: AnyPublisher<UNAuthorizationStatus, Never> = {
        authorizationStatusPublisher.receive(on: DispatchQueue.main).eraseToAnyPublisher()
    }()
    
    var isNotificationSchedulingAllowed: Bool { isNotificationSchedulingAllowedSubject.value }
    lazy var isNotificationSchedulingAllowedPublisher: AnyPublisher<Bool, Never> = {
        isNotificationSchedulingAllowedSubject.receive(on: DispatchQueue.main).eraseToAnyPublisher()
    }()
    
    func fetchAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            guard let self else { return }
            self.authorizationStatusSubject.send(settings.authorizationStatus)
            if settings.authorizationStatus == .authorized && self.userNotificationPreference {
                self.enableNotificationScheduling()
            }
        }
    }
    
    func requestPermission(_ handler: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge, .criticalAlert]) { granted, error in
            guard error == nil else { return }
            handler(granted)
            self.userNotificationPreference = true
            self.fetchAuthorizationStatus()
        }
    }
    
    func sendNotification(for event: MetricThresholdEvent) throws {
        
        guard authorizationStatus == .authorized else { throw Error.authorizationError }
        guard isNotificationSchedulingAllowed else { throw Error.schedulingDisabled }
        
        let content = UNMutableNotificationContent()
        content.title = title(for: event)
        content.subtitle = subtitle(for: event)
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        
        // choose a random identifier
        let request = UNNotificationRequest(identifier: event.id, content: content, trigger: trigger)
        
        // add our notification request
        center.add(request)
    }
    
    func enableNotificationScheduling() {
        switch authorizationStatus {
        case .authorized, .ephemeral, .provisional:
            isNotificationSchedulingAllowedSubject.send(true)
        case .denied:
            isNotificationSchedulingAllowedSubject.send(false)
        case .notDetermined:
            requestPermission { [weak self] isAllowed in
                guard let self else { return }
                self.isNotificationSchedulingAllowedSubject.send(isAllowed)
            }
            
        @unknown default:
            break
        }
    }
    
    func disableNotificationScheduling() {
        userNotificationPreference = false
        isNotificationSchedulingAllowedSubject.send(false)
    }
}

extension NotificationManager {
    enum Error: Swift.Error {
        /// The user has either not been prompted for authorization, or refused.
        case authorizationError
        
        /// Scheduling of notifications is not enabled
        case schedulingDisabled
    }
}
