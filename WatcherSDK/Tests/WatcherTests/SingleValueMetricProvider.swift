//
//  SingleValueMetricProvider.swift
//  
//
//  Created by Dorian Grolaux on 28/09/2022.
//

import Foundation
@testable import Watcher

class SingleValueMetricProvider: MetricProviderUseCase {
    
    static var minValue: Float = 0.0
    static var maxValue: Float = 1.0
    
    var value: Float
    
    init(min: Float = 0.0, current: Float = 0.5, max: Float = 1.0) {
        Self.minValue = min
        self.value = current
        Self.maxValue = max
    }
    
    func fetchMetric() throws -> Float {
        value
    }
}
