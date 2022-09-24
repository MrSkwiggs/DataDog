//
//  Events.ViewModel+Event.swift
//  DataDogApp
//
//  Created by Dorian Grolaux on 24/09/2022.
//

import Foundation
import Watcher

extension Events.ViewModel {
    struct Event: Codable, Identifiable {
        let id: String
        let metric: Metric
        let date: Date
    }
}

extension Events.ViewModel.Event {
    enum Metric: Codable {
        case cpu
        case memory
        case battery
    }
}
