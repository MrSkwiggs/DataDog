//
//  File.swift
//  
//
//  Created by Dorian Grolaux on 24/09/2022.
//

import Foundation

open class MetricProviderConfigurator: MetricManagerConfiguratorUseCase {
    
    // MARK: - Private
    
    
    // MARK: - Public
    
    public init(metricProvider: any MetricProviderUseCase,
                threshold: Float = 0.5,
                refreshFrequency: TimeInterval = 1.0,
                queue: DispatchQueue) {
        self.metricManager = .init(metricProvider: metricProvider,
                                   threshold: threshold,
                                   refreshFrequency: refreshFrequency,
                                   queue: queue)
    }
    
    // MARK: - Protocol Conformance
    
    public let metricManager: MetricManager
    
    public func set(refreshFrequency: TimeInterval) {
        metricManager.refreshFrequency = refreshFrequency
    }
    
    public func set(threshold: Float, range: MetricThresholdRange) {
        assertValueClamped(threshold)
        
        metricManager.set(threshold: (0.0...1.0).clamping(threshold),
                          range: range)
    }
    
    /// Used for mock purposes; interrupts the scheduled publisher updates, if applicable
    func pauseUpdates() {
//        timer.suspend()
    }
    
    /// Used for mock purposes; resumes the scheduled publisher updates, if applicable
    func resumeUpdates() {
//        timer.resume()
    }
    
    
}

/**
 /// This class actually implements the CPULoadProvider use case
 internal class CPULoadProvider: CPULoadConfiguratorUseCase {
 
 // MARK: Private
 
 private let cpuLoadWatcher: CPULoadWatcher = .init()
 private let cpuLoadSubject: CurrentValueSubject<Float, Never> = .init(0)
 private let thresholdEventSubject: CurrentValueSubject<MetricThresholdState, Never> = .init(.nominal)
 
 private var thresholdRange: MetricThresholdRange = .lower
 private lazy var timer: BackgroundTimer = { makeAndScheduleTimer() }()
 private let queue: DispatchQueue
 
 private func updateTimer() {
 timer = makeAndScheduleTimer()
 }
 
 private func computeThresholdState() {
 let metric = cpuLoadSubject.value
 
 let thresholdEvent = thresholdRange.mapToState(metric, threshold: threshold)
 
 guard thresholdEvent != thresholdEventSubject.value else { return }
 
 thresholdEventSubject.send(thresholdEvent)
 }
 
 private func makeAndScheduleTimer() -> BackgroundTimer {
 let timer = BackgroundTimer(timeInterval: Double(refreshFrequency), queue: queue) { [weak self] in
 guard let self else { return }
 do {
 try self.cpuLoadSubject.send(self.cpuLoadWatcher.fetchCPULoad())
 self.computeThresholdState()
 } catch let error as CPULoadWatcher.Error {
 // log error for now
 print("CPU Load Watcher error: \(error)")
 } catch {
 // TODO: needs more thorough error handling, but eventually if this fails it's not worth crashing
 // just handle silently (don't emit, but log)
 print("Unhandled error: \(error)")
 }
 }
 timer.resume()
 return timer
 }
 
 // MARK: Public
 
 public init(refreshFrequency: TimeInterval = 1, queue: DispatchQueue) {
 self.refreshFrequency = refreshFrequency
 self.queue = queue
 _ = self.timer
 }
 
 // MARK: CPULoadProviderConfigurator Conformance
 
 public lazy var publisher: AnyPublisher<Float, Never> = { cpuLoadSubject.eraseToAnyPublisher() }()
 public lazy var thresholdEventPublisher: AnyPublisher<MetricThresholdState, Never> = { thresholdEventSubject.eraseToAnyPublisher() }()
 public private(set) var threshold: Float = 1
 public private(set) var refreshFrequency: TimeInterval = 1 {
 didSet {
 updateTimer()
 }
 }
 
 public func set(refreshFrequency: TimeInterval) {
 self.refreshFrequency = refreshFrequency
 }
 
 public func set(threshold: Float, range: MetricThresholdRange) {
 self.threshold = (0.0...1.0).clamping(threshold)
 self.thresholdRange = range
 
 computeThresholdState()
 }
 
 /// Used for mock purposes; interrupts the scheduled publisher updates, if applicable
 func pauseUpdates() {
 timer.suspend()
 }
 
 /// Used for mock purposes; resumes the scheduled publisher updates, if applicable
 func resumeUpdates() {
 timer.resume()
 }
 }

 */
