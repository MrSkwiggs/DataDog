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
        
        init(futureAuthorizationStatus: UNAuthorizationStatus = .authorized) {
            self.futureAuthorizationStatus = futureAuthorizationStatus
        }
        
        private let authorizationStatusSubject: PassthroughSubject<UNAuthorizationStatus, Never> = .init()
        lazy var authorizationStatusPublisher: AnyPublisher<UNAuthorizationStatus, Never> = {
            authorizationStatusSubject.eraseToAnyPublisher()
        }()
        
        private let badgeCountSubject: CurrentValueSubject<Int, Never> = .init(0)
        lazy var badgeCountPublisher: AnyPublisher<Int, Never> = {
            badgeCountSubject.eraseToAnyPublisher()
        }()
        
        func requestPermission(_ handler: @escaping (Bool) -> Void) {
            handler(futureAuthorizationStatus == .authorized)
            authorizationStatusSubject.send(futureAuthorizationStatus)
        }
        
        func sendNotification(for event: MetricThresholdEvent) throws {
            badgeCountSubject.send(badgeCountSubject.value + 1)
        }
        
        func clearBadgeCount() {
            badgeCountSubject.send(0)
        }
    }
}
