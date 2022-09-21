//
//  CPULoadProviderUseCase.swift
//  DataDogWatchApp
//
//  Created by Dorian Grolaux on 20/09/2022.
//

import Foundation
import Combine

public protocol CPULoadProviderUseCase: MetricProviderUseCase {}

public protocol CPULoadConfiguratorUseCase: CPULoadProviderUseCase {
    /// Instructs the provider to update its refresh frequency to the given new value
    func set(refreshFrequency: Float)
}
