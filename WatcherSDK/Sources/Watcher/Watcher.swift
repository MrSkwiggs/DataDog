import Foundation

public class Watcher {
    
    public private(set) var cpuLoadWatcher: CPULoadConfiguratorUseCase
//    public private(set) var memoryLoadWatcher: MemoryLoadWatcher

    private init(cpuLoadWatcher: CPULoadConfiguratorUseCase) {
        self.cpuLoadWatcher = cpuLoadWatcher
    }
    
    public static func configure(refreshFrequency: Float) -> Watcher {
        return .default(refreshFrequency: refreshFrequency)
    }
}

private extension Watcher {
    static func `default`(refreshFrequency: Float) -> Watcher {
        let cpuLoadQueue = DispatchQueue(label: "cpu-load",
                                         qos: .background)
        return .init(cpuLoadWatcher: CPULoadProvider(refreshFrequency: refreshFrequency, queue: cpuLoadQueue))
    }
}

public extension Watcher {
    enum Configuration {
        case `default`, mock
    }
}
