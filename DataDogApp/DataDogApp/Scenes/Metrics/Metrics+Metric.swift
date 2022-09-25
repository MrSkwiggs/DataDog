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
        let isRangeInversed: Bool
        
        init(title: String, gaugeName: String, value: Float, threshold: Float, isExceedingThreshold: Bool, history: FixedSizeCollection<Float>, isRangeInversed: Bool = false) {
            self.title = title
            self.gaugeName = gaugeName
            self.value = value
            self.threshold = threshold
            self.isExceedingThreshold = isExceedingThreshold
            self.history = history
            self.isRangeInversed = isRangeInversed
        }
        
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
                Gauge(title: gaugeName, value: value, inverseRange: isRangeInversed)
                Metrics.Chart(values: history)
                    .frame(width: 150,
                           height: 50,
                           alignment: .leading)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.ui(.disabled))
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
