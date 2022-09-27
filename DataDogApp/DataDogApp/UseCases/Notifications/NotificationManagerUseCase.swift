//
//  NotificationManagerUseCase.swift
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
    
    /// The current authorization status
    var authorizationStatus: UNAuthorizationStatus { get }
    /// Publishes authorization status whenever it changes
    var authorizationStatusPublisher: AnyPublisher<UNAuthorizationStatus, Never> { get }
    
    /// Whether or not notifications can be scheduled and sent.
    var isNotificationSchedulingAllowed: Bool { get }
    /// Publishes whether or not notification scheduling is allowed whenever it changes.
    var isNotificationSchedulingAllowedPublisher: AnyPublisher<Bool, Never> { get }
    
    /// Asks the user for permission to schedule & send notifications
    ///
    /// - parameter handler: This block is called whenever the user responds to the request, with a flag that indicates whether or not the user gave their permission.
    func requestPermission(_ handler: @escaping (Bool) -> Void)
    
    /// Instructs the notification manager to schedule & send notifications
    func enableNotificationScheduling()
    
    /// Instructs the notification manager to stop scheduling & sending notifications.
    func disableNotificationScheduling()
    
    /// Schedules & sends a notifications for the given event
    ///
    /// - throws: Calling this function only allowed when the user has authorized notifications, and notification scheduling is enabled. Attempting to send a notification when either of those are pre-requisites are not fulfilled will throw a `NotificationManager.Error`
    func sendNotification(for event: MetricThresholdEvent) throws
}
