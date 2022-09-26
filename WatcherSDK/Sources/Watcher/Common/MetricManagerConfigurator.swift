//
//  MetricManagerConfigurator.swift
//  
//
//  Created by Dorian Grolaux on 24/09/2022.
//

import Foundation

/// Handles a `MetricProvider` by building a `MetricManager` and offering various configuration controls over it.
open class MetricManagerConfigurator: MetricManagerConfiguratorUseCase {
    
    // MARK: - Public
    
    public init(metricProvider: any MetricProviderUseCase,
                threshold: Float = 0.5,
                thresholdRange: MetricThresholdRange = .lower,
                refreshFrequency: TimeInterval = 1.0,
                queue: DispatchQueue) {
        self.metricManager = .init(metricProvider: metricProvider,
                                   threshold: threshold,
                                   thresholdRange: thresholdRange,
                                   refreshFrequency: refreshFrequency,
                                   queue: queue)
    }
    
    // MARK: - Protocol Conformance
    
    public let metricManager: MetricManager
    
    public func set(refreshFrequency: TimeInterval) {
        metricManager.refreshFrequency = refreshFrequency
    }
    
    public func set(threshold: Float, range: MetricThresholdRange) {
        assertValueClamped(threshold)
        
        metricManager.set(threshold: (0.0...1.0).clamping(threshold),
                          range: range)
    }
}
