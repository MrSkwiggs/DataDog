//
//  EventProvider.swift
//  
//
//  Created by Dorian Grolaux on 24/09/2022.
//

import Foundation
import Combine

public class EventProvider {
    private var eventPublishers: [MetricManagerUseCase] = []
    private var subscriptions: [AnyCancellable] = []
    
    private var subject: PassthroughSubject<MetricThresholdEvent, Never> = .init()
    
    public init() {
        
    }
    
    public func register(_ provider: MetricManagerUseCase, for metricType: MetricThresholdEvent.Metric) {
        eventPublishers.append(provider)
        provider
            .thresholdStatePublisher
            .mapToEvent(for: metricType)
            .sink { [weak self] event in
                guard let self else { return }
                self.subject.send(event)
            }
            .store(in: &subscriptions)
    }
    
    public lazy var publisher: AnyPublisher<MetricThresholdEvent, Never> = { subject.eraseToAnyPublisher() }()
}

public extension AnyPublisher where Output == MetricThresholdState {
    func mapToEvent(for metricType: MetricThresholdEvent.Metric) -> AnyPublisher<MetricThresholdEvent, Failure> {
        map {
            MetricThresholdEvent(state: $0, metric: metricType)
        }
        .eraseToAnyPublisher()
    }
}
