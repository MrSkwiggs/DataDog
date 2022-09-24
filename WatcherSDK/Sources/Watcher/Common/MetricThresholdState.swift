//
//  MetricThresholdState.swift
//  
//
//  Created by Dorian Grolaux on 21/09/2022.
//

import Foundation

/// Events emitted when metrics reach their threshold
public enum MetricThresholdState: Codable {
    /// The metric has entered the range of allotted values under its threshold
    case nominal
    /// The metric has reached and exceeded its allotted threshold value range
    case exceeded
    
    /// Whether or not this metric has exceeded its threshold
    public var isExceeding: Bool { self == .exceeded }
}
