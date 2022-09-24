//
//  MetricThresholdEvent.swift
//  
//
//  Created by Dorian Grolaux on 24/09/2022.
//

import Foundation

public struct MetricThresholdEvent: Identifiable, Codable {
    public let id: String
    public let state: MetricThresholdState
    public let metric: Metric
    public let date: Date
    
    internal init(state: MetricThresholdState, metric: Metric) {
        self.id = UUID().uuidString
        self.state = state
        self.metric = metric
        self.date = Date()
    }
}

public extension MetricThresholdEvent {
    enum Metric: Codable {
        case cpu, memory, battery
    }
}
