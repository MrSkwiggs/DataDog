//
//  MetricManager.swift
//  
//
//  Created by Dorian Grolaux on 24/09/2022.
//

import Foundation
import Combine

open class MetricManager: MetricManagerUseCase {
    
    // MARK: - Private
    
    private let metricProvider: any MetricProviderUseCase
    private let metricSubject: CurrentValueSubject<Float, Never> = .init(0)
    private let thresholdEventSubject: CurrentValueSubject<MetricThresholdState, Never> = .init(.nominal)
    
    internal private(set) var thresholdRange: MetricThresholdRange = .lower
    private lazy var timer: BackgroundTimer = { makeAndScheduleTimer() }()
    private let queue: DispatchQueue
    
    private func updateTimer() {
        timer = makeAndScheduleTimer()
    }
    
    private func computeThresholdState() {
        let metric = metricSubject.value
        
        let thresholdEvent = thresholdRange.mapToState(metric, threshold: threshold)
        
        guard thresholdEvent != thresholdEventSubject.value else { return }
        
        thresholdEventSubject.send(thresholdEvent)
    }
    
    private func makeAndScheduleTimer() -> BackgroundTimer {
        let timer = BackgroundTimer(timeInterval: Double(refreshFrequency), queue: queue) { [weak self] in
            guard let self else { return }
            do {
                try self.metricSubject.send(self.metricProvider.fetchMetric())
                self.computeThresholdState()
            } catch {
                // TODO: needs more thorough error handling, but eventually if this fails it's not worth crashing
                // just handle silently (don't emit, but log)
                print("Unhandled Metric Manager error: \(error)")
            }
        }
        timer.resume()
        return timer
    }
    
    // MARK: - Internal
    
    internal func set(threshold: Float, range: MetricThresholdRange) {
        // set the range first, as threshold events are re-calculated after mutating the threshold
        self.thresholdRange = range
        self.threshold = threshold
    }
    
    // MARK: - Public
    public init(metricProvider: any MetricProviderUseCase,
                  threshold: Float = 0.5,
                  refreshFrequency: TimeInterval = 1,
                  queue: DispatchQueue) {
        self.metricProvider = metricProvider
        self.threshold = threshold
        self.refreshFrequency = refreshFrequency
        self.queue = queue
        self.timer.resume()
    }
    
    // MARK: - Protocol Conformance
    
    public private(set) lazy var publisher: AnyPublisher<Float, Never> = {
        metricSubject.eraseToAnyPublisher()
    }()
    public private(set) var threshold: Float
    public private(set) lazy var thresholdEventPublisher: AnyPublisher<MetricThresholdState, Never> = {
        thresholdEventSubject.eraseToAnyPublisher()
    }()
    public internal(set) var refreshFrequency: TimeInterval
}
