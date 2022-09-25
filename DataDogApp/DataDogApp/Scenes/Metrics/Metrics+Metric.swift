//
//  Metrics+Metric.swift
//  DataDogApp
//
//  Created by Dorian Grolaux on 25/09/2022.
//

import SwiftUI
import Watcher

extension Metrics {
    struct Metric: View {
        
        let title: String
        let gaugeName: String
        let value: Float
        let threshold: Float
        let isExceedingThreshold: Bool
        let history: FixedSizeCollection<Float>
        
        var body: some View {
            VStack {
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.headline)
                        .bold()
                    Text("Threshold: \(threshold * 100, specifier: "%1.0f")%")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Gauge(title: gaugeName, value: value)
                Metrics.Chart(values: history)
                    .frame(width: 100,
                           height: 50,
                           alignment: .leading)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke()
//                    .fill(isExceedingThreshold ? Color.red.opacity(0.1)
//                          : Color.green.opacity(0.1))
                    .shadow(radius: 8)
            )
        }
    }
}

struct Metric_Previews: PreviewProvider {
    static var previews: some View {
        Metrics.Metric(title: "CPU Usage",
                       gaugeName: "CPU",
                       value: 0.4,
                       threshold: 0.5,
                       isExceedingThreshold: false,
                       history: Mock.chartValues)
    }
}
