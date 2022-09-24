//
//  File.swift
//  
//
//  Created by Dorian Grolaux on 24/09/2022.
//

import Foundation

/// A type that configures a metric provider
public protocol MetricManagerConfiguratorUseCase: AnyObject {
    
    associatedtype MetricManager: MetricManagerUseCase
    
    var metricManager: MetricManager { get }
    
    /// Instructs the provider to update its refresh frequency to the given new value
    func set(refreshFrequency: TimeInterval)
    
    /// Instructs the provider to update its threshold range to the given new value
    /// - Parameters:
    ///   - threshold: The new threshold value to use
    ///   - range: What range of values should be considered as _valid_ with regards to the given threshold
    func set(threshold: Float, range: MetricThresholdRange)
}
