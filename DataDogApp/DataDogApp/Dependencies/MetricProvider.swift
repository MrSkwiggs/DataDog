//
//  MetricProvider.swift
//  DataDogWatchApp
//
//  Created by Dorian Grolaux on 20/09/2022.
//

import Foundation
import Combine

protocol MetricProvider {
    var publisher: AnyPublisher<Double, Never> { get }
}
