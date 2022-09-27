//
//  MetricThresholdState.swift
//  
//
//  Created by Dorian Grolaux on 21/09/2022.
//

import Foundation

/// Events emitted when metrics reach their threshold
public enum MetricThresholdState: Codable, Equatable, CustomStringConvertible, CustomDebugStringConvertible {
    /// The metric has entered the range of allotted values under its threshold
    case nominal(value: Float, percentage: Float)
    /// The metric has reached and exceeded its allotted threshold value range
    case critical(value: Float, percentage: Float)
    
    // Override the default implementation as we don't care about the actual values for equality checks
    public static func ==(_ lhs: Self, _ rhs: Self) -> Bool {
        lhs.isCritical == rhs.isCritical
    }
    
    /// Whether or not this metric has exceeded its threshold
    public var isCritical: Bool {
        switch self {
        case .nominal:
            return false
        case .critical:
            return true
        }
    }
    
    /// The metric value associated with this state
    public var value: Float {
        switch self {
        case .nominal(let value, _),
                .critical(let value, _):
            return value
        }
    }
    
    /// The metric value associated with this state, expressed as a percentage of its min & max range
    public var percentage: Float {
        switch self {
        case .nominal(_, let percentage),
                .critical(_, let percentage):
            return percentage
        }
    }
    
    public var description: String {
        switch self {
        case .nominal:
            return "The metric has entered the range of allotted values under its threshold"
        case .critical:
            return "The metric has reached and exceeded its allotted threshold value range"
        }
    }
    
    public var debugDescription: String {
        switch self {
        case .nominal:
            return "Nominal"
        case .critical:
            return "Exceeded"
        }
    }
}
