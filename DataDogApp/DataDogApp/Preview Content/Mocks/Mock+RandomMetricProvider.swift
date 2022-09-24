//
//  Mock+RandomMetricProvider.swift
//  DataDogApp
//
//  Created by Dorian Grolaux on 24/09/2022.
//

import Foundation
import Watcher

extension Mock {
    /// Provides random values over time with some continuity between values
    class RandomMetricProvider: MetricProviderUseCase {
        
        static let minValue: Float = 0.0
        static let maxValue: Float = 1.0
        
        private var metric: Float = 0.0
        
        init(initialValue: Float = 0.0) {
            self.metric = initialValue
        }
        
        func fetchMetric() throws -> Float {
            let randomInt = Int.random(in: 0...30)
            
            let delta: Float
            // 2 chances in 30 to have a "spike" in load
            if randomInt == 0 || randomInt == 1 {
                delta = .random(in: 0.25...0.75)
            } else {
                delta = .random(in: 0.0...0.2)
            }
            
            // decide if delta is positive or negative
            let sign: Float = .random() ? 1.0 : -1.0
            
            let newValue = metric + (delta * sign)
            self.metric = (0.0...1.0).clamping(newValue)
            return metric
        }
    }
}
