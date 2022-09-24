//
//  MetricManager.swift
//  
//
//  Created by Dorian Grolaux on 24/09/2022.
//

import Foundation
import Combine

/// An object that manages a metric provider and provides convenience Combine accessors wrapped around it.
open class MetricManager: MetricManagerUseCase {
    
    // MARK: - Private
    
    /// The raw metric provider
    private let metricProvider: any MetricProviderUseCase
    
    /// The metric subject, used as a `private(set)` accessor
    private let metricSubject: PassthroughSubject<Float, Never> = .init()
    
    /// The metric's threshold events subject, used as a `private(set)` accessor
    private let thresholdEventSubject: CurrentValueSubject<MetricThresholdState, Never> = .init(.nominal)
    
    /// The metric's threshold range
    internal private(set) var thresholdRange: MetricThresholdRange = .lower
    
    /// This manager's background timer, used to repeatedly fetch the metric & publish its values
    private lazy var timer: BackgroundTimer = { makeAndScheduleTimer() }()
    
    /// The dispatch queue used by the background timer
    private let queue: DispatchQueue
    
    private func updateTimer() {
        timer = makeAndScheduleTimer()
    }
    
    private func computeThresholdState(for metricValue: Float) {
        let metric = metricValue
        
        let thresholdEvent = thresholdRange.mapToState(metric, on: type(of: metricProvider).self, threshold: threshold)
        
        // don't emit duplicate values
        guard thresholdEvent != thresholdEventSubject.value else { return }
        
        thresholdEventSubject.send(thresholdEvent)
    }
    
    private func makeAndScheduleTimer() -> BackgroundTimer {
        let timer = BackgroundTimer(timeInterval: Double(refreshFrequency), queue: queue) { [weak self] in
            guard let self else { return }
            do {
                let newValue = try self.metricProvider.fetchMetric()
                self.metricSubject.send(newValue)
                self.computeThresholdState(for: newValue)
            } catch {
                // TODO: needs more thorough error handling, but eventually if this fails it's not worth crashing
                // just handle silently (don't emit, but log) for now
                print("Unhandled Metric Manager error: \(error)")
            }
        }
        timer.resume()
        return timer
    }
    
    // MARK: - Internal
    
    internal init(metricProvider: any MetricProviderUseCase,
                  threshold: Float = 0.5,
                  refreshFrequency: TimeInterval = 1,
                  queue: DispatchQueue) {
        self.metricProvider = metricProvider
        self.threshold = threshold
        self.refreshFrequency = refreshFrequency
        self.queue = queue
        self.timer.resume()
    }
    
    internal func set(threshold: Float, range: MetricThresholdRange) {
        // set the range first, as threshold events are re-calculated after mutating the threshold
        self.thresholdRange = range
        self.threshold = threshold
    }
    
    // MARK: - Protocol Conformance
    
    public private(set) lazy var publisher: AnyPublisher<Float, Never> = {
        metricSubject.eraseToAnyPublisher()
    }()
    
    public private(set) lazy var percentagePublisher: AnyPublisher<Float, Never> = {
        metricSubject
            .compactMap { [weak self] value in
                guard let self else { return nil }
                let Limits = type(of: self.metricProvider)
                return value / Limits.maxValue
            }
            .eraseToAnyPublisher()
    }()
    
    public private(set) var threshold: Float
    public private(set) lazy var thresholdEventPublisher: AnyPublisher<MetricThresholdState, Never> = {
        thresholdEventSubject.eraseToAnyPublisher()
    }()
    public internal(set) var refreshFrequency: TimeInterval
}
