//
//  MetricProviderUseCase.swift
//  
//
//  Created by Dorian Grolaux on 24/09/2022.
//

import Foundation

public protocol MetricProviderUseCase {
    func fetchMetric() throws -> Float 
}
