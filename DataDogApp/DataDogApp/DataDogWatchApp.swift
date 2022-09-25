//
//  DataDogWatchApp.swift
//  DataDogWatchApp
//
//  Created by Dorian Grolaux on 20/09/2022.
//

import SwiftUI
import Watcher

class AppDelegate: NSObject, UIApplicationDelegate {
    
    lazy var watcher: Watcher = .configure(cpuThreshold: 0.25,
                                           memoryLoadThreshold: 0.01,
                                           batteryLevelThreshold: 0.9999,
                                           refreshFrequency: 1)
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        return true
    }
}

@main
struct DataDogApp: App {
    
    @UIApplicationDelegateAdaptor var delegate: AppDelegate
    @Environment(\.scenePhase) var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView(watcher: delegate.watcher)
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .active:
                break
            case .background:
                break
            case .inactive:
                break
                
            @unknown default:
                // ignore
                break
            }
        }
    }
}
