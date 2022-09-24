//
//  CPULoad.swift
//  
//
//  Created by Dorian Grolaux on 20/09/2022.
//

import Foundation

/// This class actually implements the CPULoadProvider use case
public class CPULoad: MetricProviderConfigurator {
    internal init(threshold: Float, refreshFrequency: TimeInterval, queue: DispatchQueue) {
        super.init(metricProvider: CPULoadWatcher(),
                   threshold: threshold,
                   refreshFrequency: refreshFrequency,
                   queue: queue)
    }
}
