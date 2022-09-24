import Foundation

public class Watcher {
    
    public private(set) var cpuLoadConfigurator: MetricProviderConfigurator
    public unowned var cpuLoad: MetricManager { cpuLoadConfigurator.metricManager }
//    public private(set) var memoryLoadWatcher: MemoryLoadWatcher

    private init(cpuLoadConfigurator: CPULoad) {
        self.cpuLoadConfigurator = cpuLoadConfigurator
    }
    
    public static func configure(cpuThreshold: Float, refreshFrequency: TimeInterval) -> Watcher {
        assertValueClamped(cpuThreshold)
        return .default(cpuThreshold: cpuThreshold, refreshFrequency: refreshFrequency)
    }
}

private extension Watcher {
    static func `default`(cpuThreshold: Float, refreshFrequency: TimeInterval) -> Watcher {
        let cpuLoadQueue = DispatchQueue(label: "cpu-load",
                                         qos: .background)
        return .init(cpuLoadConfigurator: CPULoad(threshold: cpuThreshold, refreshFrequency: refreshFrequency, queue: cpuLoadQueue))
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
