//
//  Mock+CPULoad.swift
//  DataDogWatchApp
//
//  Created by Dorian Grolaux on 20/09/2022.
//

import Foundation
import Combine

extension Mock {
    class CPULoadProvider: CPULoadProviderConfigurator {
        
        // MARK: Private
        
        private var refreshFrequency: Int = 1 {
            didSet {
                updateTimer()
            }
        }
        private let cpuLoadSubject: CurrentValueSubject<Double, Never> = .init(0)
        
        private var timer: Timer?
        
        private func updateTimer() {
            timer?.invalidate()
            timer = makeAndScheduleTimer()
        }
        
        private func makeAndScheduleTimer() -> Timer {
            Timer.scheduledTimer(withTimeInterval: Double(refreshFrequency), repeats: true, block: { [weak self] timer in
                guard let self else { return }
                self.cpuLoadSubject.send(.random(in: 0.0...1.0))
            })
        }
        
        // MARK: Public
        
        init(refreshFrequency: Int = 1) {
            self.refreshFrequency = refreshFrequency
            self.timer = makeAndScheduleTimer()
        }
        
        // MARK: CPULoadProviderConfigurator Conformance
        
        lazy var publisher: AnyPublisher<Double, Never> = { cpuLoadSubject.eraseToAnyPublisher() }()
        
        func set(refreshFrequency: Int) {
            self.refreshFrequency = refreshFrequency
        }
        
        /// Used for mock purposes; sends the given value directly to the publisher
        func send(cpuLoad: Double) {
            cpuLoadSubject.send(cpuLoad)
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
            
        }
    }
}
