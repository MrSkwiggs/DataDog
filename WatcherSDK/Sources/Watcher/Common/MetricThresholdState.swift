//
//  MetricThresholdState.swift
//  
//
//  Created by Dorian Grolaux on 21/09/2022.
//

import Foundation

/// Events emitted when metrics reach their threshold
public enum MetricThresholdState: Codable, CustomStringConvertible, CustomDebugStringConvertible {
    /// The metric has entered the range of allotted values under its threshold
    case nominal
    /// The metric has reached and exceeded its allotted threshold value range
    case exceeded
    
    /// Whether or not this metric has exceeded its threshold
    public var isExceeding: Bool { self == .exceeded }
    
    public var description: String {
        switch self {
        case .nominal:
            return "The metric has entered the range of allotted values under its threshold"
        case .exceeded:
            return "The metric has reached and exceeded its allotted threshold value range"
        }
    }
    
    public var debugDescription: String {
        switch self {
        case .nominal:
            return "Nominal"
        case .exceeded:
            return "Exceeded"
        }
    }
}
