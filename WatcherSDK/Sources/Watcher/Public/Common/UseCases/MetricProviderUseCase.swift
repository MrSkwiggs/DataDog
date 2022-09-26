//
//  MetricProviderUseCase.swift
//  
//
//  Created by Dorian Grolaux on 24/09/2022.
//

import Foundation

/// A type that provides values for a metric.
public protocol MetricProviderUseCase {
    
    /// The allotted minimum value this metric can return
    static var minValue: Float { get }
    
    /// The allotted maximum value this metric can return
    static var maxValue: Float { get }
    
    /// Fetches & computes the latest, most up-to-date value for its metric.
    func fetchMetric() throws -> Float 
}
