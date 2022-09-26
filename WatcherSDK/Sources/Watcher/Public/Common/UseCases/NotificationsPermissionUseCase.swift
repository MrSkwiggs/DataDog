//
//  NotificationsPermissionUseCase.swift
//  
//
//  Created by Dorian Grolaux on 26/09/2022.
//

import Foundation
import Combine
import UserNotifications

/// A type that can request access to the NotificationCenter and report authorisation status
public protocol NotificationsPermissionUseCase: AnyObject {
    
    var authorizationStatus: UNAuthorizationStatus { get }
    
    var authorizationStatusSubject: AnyPublisher<UNAuthorizationStatus, Never> { get }
    
    func requestPermission(_ handler: @escaping (Bool) -> Void)
}
