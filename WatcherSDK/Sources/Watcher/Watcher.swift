import Foundation

public class Watcher {
    
    public private(set) var cpuLoadManager: MetricManager

    public private(set) var memoryLoadManager: MetricManager
    
    public private(set) var batteryLevelManager: MetricManager
    
    public private(set) var eventProvider: EventProvider

    private init(cpuLoadManager: MetricManager,
                 memoryLoadManager: MetricManager,
                 batteryLevelManager: MetricManager,
                 eventProvider: EventProvider) {
        self.cpuLoadManager = cpuLoadManager
        self.memoryLoadManager = memoryLoadManager
        self.batteryLevelManager = batteryLevelManager
        self.eventProvider = eventProvider
    }
    
    public static func configure(cpuThreshold: Float = 0.25,
                                 memoryLoadThreshold: Float = 0.01,
                                 batteryLevelThreshold: Float = 0.2,
                                 refreshFrequency: TimeInterval = 1) -> Watcher {
        [cpuThreshold,
         memoryLoadThreshold,
         batteryLevelThreshold]
            .forEach(assertValueClamped)
        
        return .default(cpuThreshold: cpuThreshold,
                        memoryLoadThreshold: memoryLoadThreshold,
                        batteryLevelThreshold: batteryLevelThreshold,
                        refreshFrequency: refreshFrequency)
    }
}

private extension Watcher {
    static func `default`(cpuThreshold: Float,
                          memoryLoadThreshold: Float,
                          batteryLevelThreshold: Float,
                          refreshFrequency: TimeInterval) -> Watcher {
        let eventProvider = EventProvider()
        
        let cpuLoadQueue = DispatchQueue(label: "cpu-load",
                                         qos: .background)
        let cpuLoad = CPULoad(threshold: cpuThreshold,
                              refreshFrequency: refreshFrequency,
                              queue: cpuLoadQueue)
        eventProvider.register(cpuLoad, for: .cpu)
        
        let memoryLoadQueue = DispatchQueue(label: "memory-load",
                                         qos: .background)
        let memoryLoad = MemoryLoad(threshold: memoryLoadThreshold,
                                    refreshFrequency: refreshFrequency,
                                    queue: memoryLoadQueue)
        eventProvider.register(memoryLoad, for: .memory)
        
        let batteryLevelQueue = DispatchQueue(label: "battery-level",
                                            qos: .background)
        let batteryLevel = BatteryLevel(threshold: batteryLevelThreshold,
                                        refreshFrequency: refreshFrequency,
                                        queue: batteryLevelQueue)
        eventProvider.register(batteryLevel, for: .battery)
        
        return .init(cpuLoadManager: cpuLoad,
                     memoryLoadManager: memoryLoad,
                     batteryLevelManager: batteryLevel,
                     eventProvider: eventProvider)
    }
}

public extension Watcher {
    enum Configuration {
        case `default`, mock
    }
}

/// Ensures metric-related values (metrics themselves, or their threshold) are clamped between 0.0 & 1.0
internal func assertValueClamped(_ value: Float) {
    assert(value >= 0.0 && value <= 1.0, "Invalid metric value: \(value)")
}
