import Foundation
import BackgroundTasks
import OSLog

public class Watcher {
    
    /// The CPU Load Manager exposes CPU usage through Combine Publishers
    public private(set) var cpuLoadManager: MetricManager
    /// The Memory Load Manager exposes RAM usage through Combine Publishers
    public private(set) var memoryLoadManager: MetricManager
    /// The Battery Level Manager exposes Battery charge levels through Combine Publishers
    public private(set) var batteryLevelManager: MetricManager
    /// The Event Provider emits MetricThresholdEvents through Combine Publishers. It subscribes to all 3 metric managers by default (CPU, MEM & BAT).
    ///
    /// To only receive events for specific metrics, you can instantiate your own instance and call the `.register(_:)` function with the managers of your choice.
    public private(set) var eventProvider: EventProvider
    
    private init(cpuLoadManager: MetricManager,
                 memoryLoadManager: MetricManager,
                 batteryLevelManager: MetricManager,
                 eventProvider: EventProvider) {
        self.cpuLoadManager = cpuLoadManager
        self.memoryLoadManager = memoryLoadManager
        self.batteryLevelManager = batteryLevelManager
        self.eventProvider = eventProvider
        
        registerBackgroundTasks()
    }
    
    /// Make sure to call this function in your App's `didFinishLaunching` function, as calling it at any point later will cause a crash.
    ///
    /// The Watcher SDK registers Background Tasks, and those need to be registered before `didFinishLaunching` returns.
    /// Additionally, make sure you add the SDK's Background Task Identifier to your App's Info.plist.
    ///
    /// **Background Task Identifier**
    ///
    /// `com.datadog.watcher.background-process`
    ///
    /// - parameters:
    ///   - cpuThreshold: Percentage value the CPU Usage should reach before `.critical` ThresholdStates are emitted
    ///   - memoryLoadThreshold: Percentage value the RAM Usage should reach before `.critical` ThresholdStates are emitted
    ///   - batteryLevelThreshold: Percentage value the CPU Usage should dip below before `.critical` ThresholdStates are emitted
    ///   - refreshFrequency: Rate at which metrics should be fetched, in seconds. Lower values require more processing power, use with caution.
    /// - returns: A fully-qualified Watcher instance, ready to be used to monitor system metrics.
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
    
    private func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: Self.backgroundProcessIdentifier, using: nil) { [weak self] task in
            guard let self else { return }
            
            print("Background Task Running")
            
            try? self.cpuLoadManager.fetchOnce()
            try? self.memoryLoadManager.fetchOnce()
            try? self.batteryLevelManager.fetchOnce()
            
            task.setTaskCompleted(success: true)
            self.scheduleBackgroundTask()
        }
    }
    
    public func enableBackgroundFetching() {
        scheduleBackgroundTask()
    }
    
    private func scheduleBackgroundTask() {
        let request = BGAppRefreshTaskRequest(identifier: Self.backgroundProcessIdentifier)
        
        print("Background Task Scheduled")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 10 * 60) // Refresh after 10 minutes.
        
        do {
            try BGTaskScheduler.shared.submit(request)
            print("scheduled")
        } catch {
            print("Could not schedule background task \(error.localizedDescription)")
        }
    }
}

private extension Watcher {
    
    static let backgroundProcessIdentifier: String = "com.datadog.watcher.background-process"
    
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
