import Foundation

public class Watcher {
    
    public private(set) var cpuLoadConfigurator: MetricProviderConfigurator
    public unowned var cpuLoad: MetricManager { cpuLoadConfigurator.metricManager }

    public private(set) var memoryLoadConfigurator: MetricProviderConfigurator
    public unowned var memoryLoad: MetricManager { memoryLoadConfigurator.metricManager }

    private init(cpuLoadConfigurator: CPULoad,
                 memoryLoadConfigurator: MemoryLoad) {
        self.cpuLoadConfigurator = cpuLoadConfigurator
        self.memoryLoadConfigurator = memoryLoadConfigurator
    }
    
    public static func configure(cpuThreshold: Float,
                                 memoryLoadThreshold: Float,
                                 refreshFrequency: TimeInterval) -> Watcher {
        assertValueClamped(cpuThreshold)
        return .default(cpuThreshold: cpuThreshold,
                        memoryLoadThreshold: memoryLoadThreshold,
                        refreshFrequency: refreshFrequency)
    }
}

private extension Watcher {
    static func `default`(cpuThreshold: Float,
                          memoryLoadThreshold: Float,
                          refreshFrequency: TimeInterval) -> Watcher {
        let cpuLoadQueue = DispatchQueue(label: "cpu-load",
                                         qos: .background)
        let memoryLoadQueue = DispatchQueue(label: "memory-load",
                                         qos: .background)
        return .init(cpuLoadConfigurator: CPULoad(threshold: cpuThreshold,
                                                  refreshFrequency: refreshFrequency,
                                                  queue: cpuLoadQueue),
                     memoryLoadConfigurator: .init(threshold: memoryLoadThreshold,
                                                   refreshFrequency: refreshFrequency,
                                                   queue: memoryLoadQueue))
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
