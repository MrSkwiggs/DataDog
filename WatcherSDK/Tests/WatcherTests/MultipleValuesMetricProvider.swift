//
//  MultipleValuesMetricProvider.swift
//  
//
//  Created by Dorian Grolaux on 28/09/2022.
//

import Foundation
@testable import Watcher

class MultipleValuesMetricProvider: MetricProviderUseCase {
    static var minValue: Float = 0.0
    static var maxValue: Float = 1.0
    
    var values: [Float]
    
    init(min: Float = 0.0, values: [Float], max: Float = 1.0) {
        Self.minValue = min
        self.values = values
        Self.maxValue = max
    }
    
    func fetchMetric() throws -> Float {
        guard values.count > 1 else { return values.first! }
        return values.removeFirst()
    }
}
