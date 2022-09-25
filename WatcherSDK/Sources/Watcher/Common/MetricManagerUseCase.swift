//
//  MetricManagerUseCase.swift
//  DataDogWatchApp
//
//  Created by Dorian Grolaux on 20/09/2022.
//

import Foundation
import Combine

/// A type that manages and publishes a specific metric
public protocol MetricManagerUseCase: AnyObject {
    /// This provider's metric publisher
    var publisher: AnyPublisher<Float, Never> { get }
    
    /// This provider's metric publisher as a percentage of its min & max values
    var percentagePublisher: AnyPublisher<Float, Never> { get }
    
    /// This provider's threshold value publisher
    var thresholdPublisher: AnyPublisher<Float, Never> { get }
    /// Emits threshold state events (whenever this provider's metric transitions through its threshold)
    var thresholdStatePublisher: AnyPublisher<MetricThresholdState, Never> { get }
    
    /// This provider's refresh frequency (how often it emits through its `publisher`, in seconds.
    var refreshFrequency: TimeInterval { get }
}

