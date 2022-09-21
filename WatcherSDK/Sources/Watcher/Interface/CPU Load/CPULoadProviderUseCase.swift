//
//  CPULoadProviderUseCase.swift
//  DataDogWatchApp
//
//  Created by Dorian Grolaux on 20/09/2022.
//

import Foundation
import Combine

/// Namespaced UseCase to enforce separation
/// (prevents only having to specify `MetricProviderUseCase` and being able to pass different metric providers all willy-nilly)
public protocol CPULoadProviderUseCase: MetricProviderUseCase {
    var threshold: Float { get }
    var thresholdEventPublisher: AnyPublisher<MetricThresholdState, Never> { get }
}

public protocol CPULoadConfiguratorUseCase: CPULoadProviderUseCase {
    /// Instructs the provider to update its refresh frequency to the given new value
    func set(refreshFrequency: Float)
    
    /// Instructs the provider to update its threshold range to the given new value
    /// - Parameters:
    ///     - threshold: The new threshold value to use
    ///     - range: What range of values should be considered as _under_ the given threshold
    func set(threshold: Float, range: MetricThresholdRange)
}
