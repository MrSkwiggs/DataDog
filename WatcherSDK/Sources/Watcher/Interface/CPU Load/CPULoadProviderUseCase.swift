//
//  CPULoadProviderUseCase.swift
//  DataDogWatchApp
//
//  Created by Dorian Grolaux on 20/09/2022.
//

import Foundation
import Combine

/// Namespaced UseCase to enforce separation
/// (prevents only having to specify `MetricProviderUseCase` and being able to pass different metric providers all willy-nilly)
public protocol CPULoadProviderUseCase: MetricManagerUseCase {
}

public protocol CPULoadConfiguratorUseCase: CPULoadProviderUseCase {
    
}
