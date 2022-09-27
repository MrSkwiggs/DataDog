//
//  ViewModelProvider.swift
//  DataDogApp
//
//  Created by Dorian Grolaux on 25/09/2022.
//

import Foundation
import Watcher

class ViewModelProvider: ObservableObject {
    let watcher: Watcher
    let notificationManager: NotificationManagerUseCase
    let appManager: AppManagerUseCase
    
    init(watcher: Watcher,
         notificationManager: NotificationManagerUseCase,
         appManager: AppManagerUseCase) {
        self.watcher = watcher
        self.notificationManager = notificationManager
        self.appManager = appManager
    }
    
    var rootViewModel: RootView.ViewModel {
        .init(appManager: appManager)
    }
    
    var metricsViewModel: Metrics.ViewModel {
        .init(cpuLoadManager: watcher.cpuLoadManager,
              memoryLoadManager: watcher.memoryLoadManager,
              batteryLevelManager: watcher.batteryLevelManager)
//        .init(cpuLoadProvider: Mock.MetricConfigurator(initialValue: 0,
//                                                       threshold: 1,
//                                                       refreshFrequency: 1.0 / 60.0).metricManager,
//              memoryLoadProvider: watcher.memoryLoad,
//              batteryStateProvider: watcher.batteryLevel)
    }
    
    var eventsViewModel: Events.ViewModel {
        .init(appManager: appManager)
    }
}
