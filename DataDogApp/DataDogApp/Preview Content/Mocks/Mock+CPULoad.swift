//
//  Mock+CPULoad.swift
//  DataDogWatchApp
//
//  Created by Dorian Grolaux on 20/09/2022.
//

import Foundation
import Combine
import Watcher

extension Mock {
    class CPULoadProvider: CPULoadConfiguratorUseCase {
        
        // MARK: Private
        
        private var refreshFrequency: Float = 1 {
            didSet {
                updateTimer()
            }
        }
        private let cpuLoadSubject: CurrentValueSubject<Float, Never> = .init(0)
        private let thresholdEventSubject: CurrentValueSubject<MetricThresholdState, Never> = .init(.nominal)
        
        private var thresholdRange: MetricThresholdRange = .lower
        private var timer: Timer?
        
        private func updateTimer() {
            timer?.invalidate()
            timer = makeAndScheduleTimer()
        }
        
        private func computeThresholdState() {
            let metric = cpuLoadSubject.value
            
            let thresholdEvent = thresholdRange.mapToState(metric, threshold: threshold)
            
            guard thresholdEvent != thresholdEventSubject.value else { return }
            
            thresholdEventSubject.send(thresholdEvent)
        }
        
        private func makeAndScheduleTimer() -> Timer {
            Timer.scheduledTimer(withTimeInterval: Double(refreshFrequency), repeats: true, block: { [weak self] timer in
                guard let self else { return }
                let randomInt = Int.random(in: 0...30)
                
                let delta: Float
                // 2 chances in 20 to have a "spike" in load
                if randomInt == 0 || randomInt == 1 {
                    delta = .random(in: 0.25...0.75)
                } else {
                    delta = .random(in: 0.0...0.2)
                }
                
                let sign: Float
                // decide if delta is positive or negative
                if .random() {
                    sign = 1.0
                } else {
                    sign = -1.0
                }
                
                let newValue = self.cpuLoadSubject.value + (delta * sign)
                self.cpuLoadSubject.send((0.0...1.0).clamping(newValue))
                self.computeThresholdState()
            })
        }
        
        // MARK: Public
        
        init(refreshFrequency: Float = 1) {
            self.refreshFrequency = refreshFrequency
            self.timer = makeAndScheduleTimer()
        }
        
        // MARK: CPULoadProviderConfigurator Conformance
        
        lazy var publisher: AnyPublisher<Float, Never> = { cpuLoadSubject.eraseToAnyPublisher() }()
        lazy var thresholdEventPublisher: AnyPublisher<MetricThresholdState, Never> = { thresholdEventSubject.eraseToAnyPublisher() }()
        private(set) var threshold: Float = 1.0
        
        func set(refreshFrequency: Float) {
            self.refreshFrequency = refreshFrequency
        }
        
        /// Used for mock purposes; sends the given value directly to the publisher
        func send(cpuLoad: Float) {
            cpuLoadSubject.send(cpuLoad)
        }
        
        public func set(threshold: Float, range: MetricThresholdRange) {
            self.threshold = (0.0...1.0).clamping(threshold)
            self.thresholdRange = range
            
            computeThresholdState()
        }
        
        /// Used for mock purposes; interrupts the scheduled publisher updates, if applicable
        func pauseUpdates() {
            guard let timer else { return }
            timer.invalidate()
            self.timer = nil
        }
        
        /// Used for mock purposes; resumes the scheduled publisher updates, if applicable
        func resumeUpdates() {
            guard timer == nil else { return }
            self.timer = makeAndScheduleTimer()
        }
    }
}
