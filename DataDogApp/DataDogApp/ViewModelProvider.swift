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
    
    init(watcher: Watcher) {
        self.watcher = watcher
    }
    
    var rootViewModel: RootView.ViewModel {
        .init(eventProvider: watcher.eventProvider)
    }
    
    var metricsViewModel: Metrics.ViewModel {
        .init(cpuLoadProvider: watcher.cpuLoad,
              memoryLoadProvider: watcher.memoryLoad,
              batteryStateProvider: watcher.batteryLevel)
    }
    
    var eventsViewModel: Events.ViewModel {
        .init(eventProvider: watcher.eventProvider)
    }
}
