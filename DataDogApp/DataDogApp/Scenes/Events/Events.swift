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
            Section {
                Toggle("Show Nominal Events", isOn: $viewModel.showsNominalEvents)
                    .padding(.vertical, 4)
                    .onTapGesture {
                        viewModel.showsNominalEvents.toggle()
                    }
            }
            if viewModel.events.isEmpty {
                Text("No events... yet 🫢")
            } else {
                ForEach(viewModel.events) { event in
                    HStack {
                        rowHeader(date: event.date,
                                  metric: event.metricType,
                                  percentage: event.state.percentage)
                        Spacer()
                        state(event.state)
                    }
                }
            }
        }
        .animation(.default, value: viewModel.showsNominalEvents)
        .navigationTitle("Events")
    }
    
    private func rowHeader(date: Date,
                           metric: MetricType,
                           percentage: Float) -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text("\(metric.rawValue)")
                    .bold()
                Text("- \(percentage * 100, specifier: "%0.0f")%")
            }
            Text(date, style: .relative) + Text(" ago")
        }
    }
    
    private func state(_ state: MetricThresholdState) -> some View {
        Text(state.debugDescription)
            .bold()
            .foregroundColor(state.isCritical ? .red : .green)
    }
}

struct Events_Previews: PreviewProvider {
    
    static let eventProvider: EventProvider = {
        let eventProvider = EventProvider()
        eventProvider.register(Mock.RandomEventMetricManager(refreshFrequency: 3), for: .cpu)
        return eventProvider
    }()
    
    static var previews: some View {
        Events(viewModel: .init(appManager: Mock.AppManager()))
    }
}
