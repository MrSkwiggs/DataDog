//
//  AppManager.swift
//  DataDogApp
//
//  Created by Dorian Grolaux on 27/09/2022.
//

import Foundation
import UIKit
import Combine
import Watcher

class AppManager: AppManagerUseCase {
    
    // MARK: - Private
    
    private let reportNominalEventsTooSubject: CurrentValueSubject<Bool, Never> = .init(false)
    private let unseenEventsNumberSubject: CurrentValueSubject<Int, Never> = .init(0)
    private let eventsSubject: CurrentValueSubject<[MetricThresholdEvent], Never> = .init([])
    
    private let eventProvider: EventProvider
    private let notificationManager: NotificationManagerUseCase
    
    private var allEvents: [MetricThresholdEvent] = []
    private var subscriptions: [AnyCancellable] = []
    
    init(eventProvider: EventProvider, notificationManager: NotificationManagerUseCase) {
        self.eventProvider = eventProvider
        self.notificationManager = notificationManager
        
        setupSubscriptions()
    }
    
    private func setupSubscriptions() {
        eventProvider
            .publisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                guard let self else { return }
                self.allEvents.append(event)
                if self.reportNominalEventsTooSubject.value || event.state.isExceeding {
                    self.unseenEventsNumberSubject.increment()
                }
                self.publishChanges()
            }
            .store(in: &subscriptions)
    }
    
    private func publishChanges() {
        eventsSubject
            .send(
                allEvents
                    .filter({ event in
                        reportNominalEventsTooSubject.value ? true : event.state.isExceeding
                    })
                    .reversed()
            )
    }
    
    // MARK: - Protocol Conformance
    
    lazy var reportNominalEventsTooPublisher: AnyPublisher<Bool, Never> = {
        reportNominalEventsTooSubject.eraseToAnyPublisher()
    }()
    lazy var unseenEventsNumberPublisher: AnyPublisher<Int, Never> = {
        unseenEventsNumberSubject.eraseToAnyPublisher()
    }()
    lazy var eventsPublisher: AnyPublisher<[MetricThresholdEvent], Never> = {
        eventsSubject.eraseToAnyPublisher()
    }()
    
    func setShouldReportNominalEventsToo(_ shouldReport: Bool) {
        reportNominalEventsTooSubject.send(shouldReport)
        publishChanges()
    }
    
    func markAllEventsAsSeen() {
        unseenEventsNumberSubject.send(0)
    }
}
