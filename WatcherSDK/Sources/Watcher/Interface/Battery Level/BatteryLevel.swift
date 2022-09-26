//
//  BatteryLevel.swift
//  
//
//  Created by Dorian Grolaux on 24/09/2022.
//

import Foundation

/// Implementation of the battery level provider
public class BatteryLevel: MetricManager {
    internal init(threshold: Float, refreshFrequency: TimeInterval, queue: DispatchQueue) {
        super.init(metricProvider: BatteryWatcher(),
                   threshold: threshold,
                   thresholdRange: .upper,
                   refreshFrequency: refreshFrequency,
                   queue: queue)
        
    }
}
