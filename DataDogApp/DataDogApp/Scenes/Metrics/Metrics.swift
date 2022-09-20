//
//  Metrics.swift
//  DataDogWatchApp
//
//  Created by Dorian Grolaux on 20/09/2022.
//

import SwiftUI

struct Metrics: View {
    
    let gradient = Gradient(colors: [.green, .orange, .red])

    @StateObject
    var viewModel: ViewModel
    
    var body: some View {
        
        Gauge(value: viewModel.cpuLoad, label: {
            Text("CPU")
        }, currentValueLabel: {
            Text("\(viewModel.cpuLoad * 100)%")
        })
        .scaleEffect(1.5)
        .gaugeStyle(.accessoryCircular)
        .tint(gradient)
        .animation(.default, value: viewModel.cpuLoad)
    }
}

struct Metrics_Previews: PreviewProvider {
    static var previews: some View {
        Metrics(viewModel: .init(cpuLoadProvider: Mock.CPULoadProvider()))
    }
}
