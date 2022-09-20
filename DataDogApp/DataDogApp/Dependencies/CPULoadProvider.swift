//
//  CPULoadProvider.swift
//  DataDogWatchApp
//
//  Created by Dorian Grolaux on 20/09/2022.
//

import Foundation
import Combine

protocol CPULoadProvider: MetricProvider {}

protocol CPULoadProviderConfigurator: CPULoadProvider {
    func set(refreshFrequency: Int)
}
