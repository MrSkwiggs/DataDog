//
//  Mock+NotificationManager.swift
//  DataDogApp
//
//  Created by Dorian Grolaux on 27/09/2022.
//

import Foundation
import UserNotifications
import Combine
import Watcher

extension Mock {
    class NotificationManager: NotificationManagerUseCase {
        
        private let futureAuthorizationStatus: UNAuthorizationStatus
        
        private let authorizationStatusSubject: CurrentValueSubject<UNAuthorizationStatus, Never> = .init(.notDetermined)
        private let isNotificationSchedulingAllowedSubject: CurrentValueSubject<Bool, Never> = .init(false)
        
        init(futureAuthorizationStatus: UNAuthorizationStatus = .authorized) {
            self.futureAuthorizationStatus = futureAuthorizationStatus
        }
        
        var authorizationStatus: UNAuthorizationStatus  { authorizationStatusSubject.value }
        lazy var authorizationStatusPublisher: AnyPublisher<UNAuthorizationStatus, Never> = {
            authorizationStatusPublisher.eraseToAnyPublisher()
        }()
        
        var isNotificationSchedulingAllowed: Bool { isNotificationSchedulingAllowedSubject.value }
        lazy var isNotificationSchedulingAllowedPublisher: AnyPublisher<Bool, Never> = {
            isNotificationSchedulingAllowedSubject.eraseToAnyPublisher()
        }()
        
        func fetchAuthorizationStatus() {
            // do nothing
        }
        
        func requestPermission(_ handler: @escaping (Bool) -> Void) {
            handler(futureAuthorizationStatus == .authorized)
            authorizationStatusSubject.send(futureAuthorizationStatus)
        }
        
        func sendNotification(for event: MetricThresholdEvent) throws {
            // ignore
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
            isNotificationSchedulingAllowedSubject.send(false)
        }
    }
}
