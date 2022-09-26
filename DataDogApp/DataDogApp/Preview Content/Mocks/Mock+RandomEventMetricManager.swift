//
//  Mock+RandomEventMetricManager.swift
//  DataDogApp
//
//  Created by Dorian Grolaux on 25/09/2022.
//

import Foundation
import Combine
import Watcher

extension Mock {
    /// Provides random threshold events over time
    class RandomEventMetricManager: MetricManagerUseCase {
        // MARK: - Unused
        var publisher: AnyPublisher<Float, Never> = Just(0.0).eraseToAnyPublisher()
        var percentagePublisher: AnyPublisher<Float, Never> = Just(0.0).eraseToAnyPublisher()
        var thresholdPublisher: AnyPublisher<Float, Never> = Just(0.0).eraseToAnyPublisher()
        var history: FixedSizeCollection<Float> = []
        var percentageHistory: FixedSizeCollection<Float> = []
        var threshold: Float = 0.0
        var thresholdRange: MetricThresholdRange = .lower
        var thresholdRangePublisher: AnyPublisher<MetricThresholdRange, Never> = Just(.lower).eraseToAnyPublisher()
        var refreshFrequencyPublisher: AnyPublisher<TimeInterval, Never> = Just(0.0).eraseToAnyPublisher()
        
        
        // MARK: - Mock
        private var thresholdStateSubject: CurrentValueSubject<MetricThresholdState, Never> = .init(.nominal(value: 0, percentage: 0))
        lazy var thresholdStatePublisher: AnyPublisher<MetricThresholdState, Never> = {
            thresholdStateSubject.eraseToAnyPublisher()
        }()
        var refreshFrequency: TimeInterval
        
        private var timer: Timer?
        
        init(refreshFrequency: TimeInterval = 1) {
            self.refreshFrequency = refreshFrequency
            self.timer = Timer.scheduledTimer(withTimeInterval: refreshFrequency, repeats: true, block: { [weak self] timer in
                guard let self else { return }
                self.thresholdStateSubject.send(.random() ? .nominal(value: 0, percentage: 0) : .exceeded(value: 1, percentage: 1))
            })
        }
    }
}
