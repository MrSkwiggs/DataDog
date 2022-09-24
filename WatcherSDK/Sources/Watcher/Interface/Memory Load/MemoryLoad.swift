//
//  MemoryLoad.swift
//  
//
//  Created by Dorian Grolaux on 24/09/2022.
//

import Foundation

/// Implementation of the memory load provider
public class MemoryLoad: MetricProviderConfigurator {
    internal init(threshold: Float, refreshFrequency: TimeInterval, queue: DispatchQueue) {
        super.init(metricProvider: MemoryLoadWatcher(),
                   threshold: threshold,
                   refreshFrequency: refreshFrequency,
                   queue: queue)
    }
}
