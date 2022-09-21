//
//  MetricProvider.swift
//  DataDogWatchApp
//
//  Created by Dorian Grolaux on 20/09/2022.
//

import Foundation
import Combine

/// A type that publishes a specific metric
public protocol MetricProviderUseCase {
    /// This provider's metric publisher
    var publisher: AnyPublisher<Float, Never> { get }
}
