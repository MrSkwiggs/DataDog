//
//  MetricProviderUseCase.swift
//  
//
//  Created by Dorian Grolaux on 24/09/2022.
//

import Foundation

/// A type that provides values for a metric.
public protocol MetricProviderUseCase {
    
    /// Fetches & computes the latest, most up-to-date value for its metric.
    func fetchMetric() throws -> Float 
}
