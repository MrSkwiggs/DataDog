//
//  MetricType.swift
//  
//
//  Created by Dorian Grolaux on 25/09/2022.
//

import Foundation

public enum MetricType: String, Equatable, Codable, CustomStringConvertible, CustomDebugStringConvertible {
    case cpu = "CPU"
    case memory = "MEM"
    case battery = "BAT"
    
    public var description: String {
        switch self {
        case .cpu: return "CPU Usage"
        case .memory: return "Memory Usage"
        case .battery: return "Battery Level"
        }
    }
    
    public var debugDescription: String { rawValue }
}
