import Foundation

public class Watcher {
    
    public private(set) var cpuLoadConfigurator: MetricManagerConfigurator
    public unowned var cpuLoad: MetricManager { cpuLoadConfigurator.metricManager }

    public private(set) var memoryLoadConfigurator: MetricManagerConfigurator
    public unowned var memoryLoad: MetricManager { memoryLoadConfigurator.metricManager }
    
    public private(set) var batteryLevelConfigurator: MetricManagerConfigurator
    public unowned var batteryLevel: MetricManager { batteryLevelConfigurator.metricManager }
    
    public private(set) var eventProvider: EventProvider

    private init(cpuLoadConfigurator: CPULoad,
                 memoryLoadConfigurator: MemoryLoad,
                 batteryLevelConfigurator: BatteryLevel,
                 eventProvider: EventProvider) {
        self.cpuLoadConfigurator = cpuLoadConfigurator
        self.memoryLoadConfigurator = memoryLoadConfigurator
        self.batteryLevelConfigurator = batteryLevelConfigurator
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
        eventProvider.register(cpuLoad.metricManager, for: .cpu)
        
        let memoryLoadQueue = DispatchQueue(label: "memory-load",
                                         qos: .background)
        let memoryLoad = MemoryLoad(threshold: memoryLoadThreshold,
                                    refreshFrequency: refreshFrequency,
                                    queue: memoryLoadQueue)
        eventProvider.register(memoryLoad.metricManager, for: .memory)
        
        let batteryLevelQueue = DispatchQueue(label: "battery-level",
                                            qos: .background)
        let batteryLevel = BatteryLevel(threshold: batteryLevelThreshold,
                                        refreshFrequency: refreshFrequency,
                                        queue: batteryLevelQueue)
        eventProvider.register(batteryLevel.metricManager, for: .battery)
        
        return .init(cpuLoadConfigurator: cpuLoad,
                     memoryLoadConfigurator: memoryLoad,
                     batteryLevelConfigurator: batteryLevel,
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
