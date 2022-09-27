//
//  EventProvider.swift
//  
//
//  Created by Dorian Grolaux on 24/09/2022.
//

import Foundation
import Combine

/// The Event Provider listens to `MetricThresholdState` publishers and maps them to a continuous stream of `MetricTresholdEvent`.
///
/// - important: Make sure to properly register your `MetricManager`(s) with the `EventProvider` ahead of time.
public class EventProvider {
    private var eventPublishers: [MetricManagerUseCase] = []
    private var subscriptions: [AnyCancellable] = []
    
    private var subject: PassthroughSubject<MetricThresholdEvent, Never> = .init()
    
    public init() {}
    
    /// Registers the the given metric manager with this event provider, so that it can listen to State Events and re-publish Events from them.
    /// - Parameters:
    ///  - manager: The metric manager to use
    ///  - metricType: The type of metric to report this in the generated events.
    public func register(_ manager: MetricManagerUseCase, for metricType: MetricType) {
        eventPublishers.append(manager)
        manager
            .thresholdStatePublisher
            .mapToEvent(for: metricType)
            .sink { [weak self] event in
                guard let self else { return }
                /// update the events array before emitting 
                self.events.append(event)
                self.subject.send(event)
            }
            .store(in: &subscriptions)
    }
    
    /// This provider's event publisher
    public lazy var publisher: AnyPublisher<MetricThresholdEvent, Never> = { subject.eraseToAnyPublisher() }()
    public var events: [MetricThresholdEvent] = []
}

public extension AnyPublisher where Output == MetricThresholdState {
    func mapToEvent(for type: MetricType) -> AnyPublisher<MetricThresholdEvent, Failure> {
        map {
            MetricThresholdEvent(state: $0,
                                 metricType: type)
        }
        .eraseToAnyPublisher()
    }
}
