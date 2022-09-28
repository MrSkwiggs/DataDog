//
//  DataDogWatchApp.swift
//  DataDogWatchApp
//
//  Created by Dorian Grolaux on 20/09/2022.
//

import SwiftUI
import Combine
import Watcher

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    private lazy var watcher: Watcher = .configure(cpuThreshold: 0.95,
                                                   memoryLoadThreshold: 0.2,
                                                   batteryLevelThreshold: 0.2,
                                                   refreshFrequency: 0.3)
    
    lazy var viewModelProvider: ViewModelProvider = {
        let notificationManager = NotificationManager()
        return .init(watcher: watcher,
                     notificationManager: notificationManager,
                     appManager: AppManager(eventProvider: watcher.eventProvider,
                                            notificationManager: notificationManager))
    }()
    
    private var subscriptions: [AnyCancellable] = []
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        viewModelProvider
            .appManager
            .unseenEventsNumberPublisher
            .sink { value in
                UIApplication.shared.applicationIconBadgeNumber = value
            }
            .store(in: &subscriptions)
        
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }
    
    func sceneEnteredBackground() {
        viewModelProvider.watcher.enableBackgroundFetching()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .badge, .sound])
    }
}

@main
struct DataDogApp: App {
    
    @Environment(\.scenePhase) var scenePhase
    
    @UIApplicationDelegateAdaptor
    var delegate: AppDelegate
    
    var body: some Scene {
        WindowGroup {
            RootView(viewModel: delegate.viewModelProvider.rootViewModel)
                .environmentObject(delegate.viewModelProvider)
        }
        .onChange(of: scenePhase) { scenePhase in
            switch scenePhase {
            case .active:
                break
            case .background:
                delegate.sceneEnteredBackground()

            case .inactive:
                break

            @unknown default:
                break
            }
        }
    }
}
