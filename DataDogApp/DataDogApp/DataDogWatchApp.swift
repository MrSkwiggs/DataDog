//
//  DataDogWatchApp.swift
//  DataDogWatchApp
//
//  Created by Dorian Grolaux on 20/09/2022.
//

import SwiftUI
import Watcher

class AppDelegate: NSObject, UIApplicationDelegate {
    
    private lazy var watcher: Watcher = .configure(cpuThreshold: 0.25,
                                           memoryLoadThreshold: 0.01,
                                           batteryLevelThreshold: 0.9999,
                                           refreshFrequency: 1)
    
    var viewModelProvider: ViewModelProvider!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        viewModelProvider = .init(watcher: watcher)
        return true
    }
}

@main
struct DataDogApp: App {
    
    @UIApplicationDelegateAdaptor
    var delegate: AppDelegate
    
    var body: some Scene {
        WindowGroup {
            RootView(viewModel: delegate.viewModelProvider.rootViewModel)
                .environmentObject(delegate.viewModelProvider)
        }
    }
}
