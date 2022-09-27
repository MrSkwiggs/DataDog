//
//  AppManager.swift
//  DataDogApp
//
//  Created by Dorian Grolaux on 27/09/2022.
//

import Foundation
import Combine
import Watcher

/// A type that manages various aspects of the app
protocol AppManagerUseCase: AnyObject {
    
    /// Publishes whether or not the app should report nominal events, too
    ///
    /// By default, only critical events are reported
    var reportNominalEventsTooPublisher: AnyPublisher<Bool, Never> { get }
    
    /// Publishes the number of "unseen" events
    var unseenEventsNumberPublisher: AnyPublisher<Int, Never> { get }
    
    /// Publishes a list of recent events
    var eventsPublisher: AnyPublisher<[MetricThresholdEvent], Never> { get }
    
    /// Instructs this manager whether or not it should report nominal events, too
    func setShouldReportNominalEventsToo(_ shouldReport: Bool)
    
    /// Instructs this manager to clear the unseen event number
    func markAllEventsAsSeen()
}
