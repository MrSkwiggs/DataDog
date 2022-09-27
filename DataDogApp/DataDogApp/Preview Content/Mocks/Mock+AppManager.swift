//
//  Mock+AppManager.swift
//  DataDogApp
//
//  Created by Dorian Grolaux on 27/09/2022.
//

import Foundation
import Combine
import Watcher

extension Mock {
    class AppManager: AppManagerUseCase {
        
        var reportNominalEventsTooPublisher: AnyPublisher<Bool, Never> = Just(true).eraseToAnyPublisher()
        var unseenEventsNumberPublisher: AnyPublisher<Int, Never> = Just(3).eraseToAnyPublisher()
        var eventsPublisher: AnyPublisher<[MetricThresholdEvent], Never> = Just([]).eraseToAnyPublisher()
        
        func setShouldReportNominalEventsToo(_ shouldReport: Bool) {
            //
        }
        
        func markAllEventsAsSeen() {
            //
        }
    }
}
