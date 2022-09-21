//
//  File.swift
//  
//
//  Created by Dorian Grolaux on 20/09/2022.
//

import Foundation
import Combine

public class CPULoadProvider: CPULoadConfiguratorUseCase {
    
    // MARK: Private
    
    private let cpuLoadWatcher: CPULoadWatcher = .init()
    private var refreshFrequency: Float = 1 {
        didSet {
            updateTimer()
        }
    }
    private let cpuLoadSubject: CurrentValueSubject<Float, Never> = .init(0)
    private lazy var timer: BackgroundTimer = { makeAndScheduleTimer() }()
    private let queue: DispatchQueue
    
    private func updateTimer() {
        timer = makeAndScheduleTimer()
    }
    
    private func makeAndScheduleTimer() -> BackgroundTimer {
        let timer = BackgroundTimer(timeInterval: Double(refreshFrequency), queue: queue) { [weak self] in
            guard let self else { return }
            
            self.cpuLoadSubject.send(self.cpuLoadWatcher.fetchCPULoad())
        }
        timer.resume()
        return timer
    }
    
    // MARK: Public
    
    public init(refreshFrequency: Float = 1, queue: DispatchQueue) {
        self.refreshFrequency = refreshFrequency
        self.queue = queue
        _ = self.timer
    }
    
    // MARK: CPULoadProviderConfigurator Conformance
    
    public lazy var publisher: AnyPublisher<Float, Never> = { cpuLoadSubject.eraseToAnyPublisher() }()
    
    public func set(refreshFrequency: Float) {
        self.refreshFrequency = refreshFrequency
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
