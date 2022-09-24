//
//  BackgroundTimer.swift
//  
//
//  Created by Dorian Grolaux on 20/09/2022.
//

import Foundation

/// A timer that runs on a given background queue, repeating tasks at the given time interval.
class BackgroundTimer {
    
    private var timer: DispatchSourceTimer
    private var state: State = .suspended
    
    init(timeInterval: TimeInterval, queue: DispatchQueue = .global(qos: .background), handler: @escaping () -> Void) {
        let timer = DispatchSource.makeTimerSource(queue: queue)
        timer.schedule(deadline: .now() + timeInterval,
                       repeating: timeInterval)
        timer.setEventHandler(handler: handler)
        self.timer = timer
    }
    
    /// Resumes this timer, if not already running
    func resume() {
        guard state != .running else { return }
        state = .running
        timer.resume()
    }
    
    /// Suspends this timer, if not already suspended
    func suspend() {
        guard state != .suspended else { return }
        state = .suspended
        timer.suspend()
    }
    
    deinit {
        timer.setEventHandler {}
        timer.cancel()
        /*
         If the timer is suspended, calling cancel without resuming
         triggers a crash. This is documented here
         https://forums.developer.apple.com/thread/15902
         */
        resume()
    }
}

private extension BackgroundTimer {
    /**
     Whether or not the Timer is running
     */
    enum State {
        case suspended
        case running
    }
}
