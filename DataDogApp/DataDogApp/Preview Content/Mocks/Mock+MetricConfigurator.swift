//
//  Mock+MetricConfigurator.swift
//  DataDogApp
//
//  Created by Dorian Grolaux on 24/09/2022.
//

import Foundation
import Watcher

extension Mock {
    class MetricConfigurator: MetricManagerConfigurator {
        init(initialValue: Float = 0.0, threshold: Float = 0.5, refreshFrequency: TimeInterval = 1) {
            super.init(metricProvider: RandomMetricProvider(),
                       threshold: threshold,
                       refreshFrequency: refreshFrequency,
                       queue: .init(label: UUID().uuidString, qos: .background))
        }
    }
}
