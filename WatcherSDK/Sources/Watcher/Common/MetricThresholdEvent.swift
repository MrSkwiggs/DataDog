//
//  MetricThresholdEvent.swift
//  
//
//  Created by Dorian Grolaux on 24/09/2022.
//

import Foundation

public struct MetricThresholdEvent: Identifiable, Equatable, Codable {
    public let id: String
    public let state: MetricThresholdState
    public let metric: MetricType
    public let date: Date
    
    internal init(state: MetricThresholdState, metric: MetricType) {
        self.id = UUID().uuidString
        self.state = state
        self.metric = metric
        self.date = Date()
    }
}
