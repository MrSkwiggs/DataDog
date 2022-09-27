//
//  NotificationsPermissionUseCase.swift
//  
//
//  Created by Dorian Grolaux on 26/09/2022.
//

import Foundation
import Combine
import UserNotifications
import Watcher

/// A type that can request access to the NotificationCenter and report authorization status
public protocol NotificationManagerUseCase: AnyObject {
    /// Publishes authorization status whenever it changes
    var authorizationStatusPublisher: AnyPublisher<UNAuthorizationStatus, Never> { get }
    
    /// Asks the user for permission to schedule & send notifications
    ///
    /// - parameter handler: This block is called whenever the user responds to the request, with a flag that indicates whether or not the user gave their permission.
    func requestPermission(_ handler: @escaping (Bool) -> Void)
    
    /// Schedules & sends a notifications for the given event
    func sendNotification(for event: MetricThresholdEvent) throws
}
