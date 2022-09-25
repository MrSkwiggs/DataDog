//
//  Events.swift
//  DataDogWatchApp
//
//  Created by Dorian Grolaux on 20/09/2022.
//

import SwiftUI
import Watcher

struct Events: View {
    
    @StateObject
    var viewModel: ViewModel
    
    var body: some View {
        List {
            ForEach(viewModel.events.reversed()) { event in
                HStack {
                    rowHeader(date: event.date,
                              metric: event.metric)
                    Spacer()
                    state(event.state)
                }
            }
        }
    }
    
    private func rowHeader(date: Date, metric: MetricThresholdEvent.Metric) -> some View {
        VStack(alignment: .leading) {
            Text("\(metric.rawValue)")
                .bold()
            Text(date, style: .relative) + Text(" ago")
        }
    }
    
    private func state(_ state: MetricThresholdState) -> some View {
        Text(state.debugDescription)
            .bold()
            .foregroundColor(state.isExceeding ? .red : .green)
    }
}

struct Events_Previews: PreviewProvider {
    
    static let eventProvider: EventProvider = {
        let eventProvider = EventProvider()
        eventProvider.register(Mock.RandomEventMetricManager(refreshFrequency: 3), for: .cpu)
        return eventProvider
    }()
    
    static var previews: some View {
        Events(viewModel: .init(eventProvider: eventProvider))
    }
}
