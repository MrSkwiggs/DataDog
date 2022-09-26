//
//  CPULoad.swift
//  
//
//  Created by Dorian Grolaux on 20/09/2022.
//

import Foundation

/// Implementation of the CPU load provider
public class CPULoad: MetricManagerConfigurator {
    internal init(threshold: Float, refreshFrequency: TimeInterval, queue: DispatchQueue) {
        super.init(metricProvider: CPULoadWatcher(),
                   threshold: threshold,
                   refreshFrequency: refreshFrequency,
                   queue: queue)
    }
}
