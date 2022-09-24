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
    
    /// This provider's metric as a percentage of its min & max values
    var percentagePublisher: AnyPublisher<Float, Never> { get }
    
    /// This provider's threshold value
    var threshold: Float { get }
    /// Emits threshold state events (whenever this provider's metric transitions through its threshold)
    var thresholdEventPublisher: AnyPublisher<MetricThresholdState, Never> { get }
    /// This provider's refresh frequency (how often it emits through its `publisher`, in seconds.
    var refreshFrequency: TimeInterval { get }
}

