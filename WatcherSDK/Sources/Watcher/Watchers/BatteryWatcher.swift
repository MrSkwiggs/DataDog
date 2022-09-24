//
//  BatteryWatcher.swift
//  
//
//  Created by Dorian Grolaux on 24/09/2022.
//

import Foundation
import UIKit

class BatteryWatcher: MetricProviderUseCase {
    static let minValue: Float = 0
    static let maxValue: Float = 1
    
    init() {
        UIDevice.current.isBatteryMonitoringEnabled = true
    }
    
    deinit {
        UIDevice.current.isBatteryMonitoringEnabled = false
    }
    
    func fetchMetric() throws -> Float {
        guard UIDevice.current.batteryState != .unknown else {
            throw Error.monitoringDisabledReadAttempt
        }
        
        return UIDevice.current.batteryLevel
    }
}

extension BatteryWatcher {
    enum Error: Swift.Error {
        /// Thrown when attempting to read the battery level when battery level monitoring has not been enabled
        case monitoringDisabledReadAttempt
    }
}
