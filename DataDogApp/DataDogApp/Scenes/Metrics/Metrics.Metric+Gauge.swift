//
//  Metrics.Metric+Gauge.swift
//  DataDogApp
//
//  Created by Dorian Grolaux on 25/09/2022.
//

import SwiftUI

extension Metrics.Metric {
    struct Gauge: View {
        
        let title: String
        let value: Float
        let inverseRange: Bool
        
        init(title: String, value: Float, inverseRange: Bool = false) {
            self.title = title
            self.value = value
            self.inverseRange = inverseRange
        }
        
        var gradientColors: [Color] {
            let colors: [Color] = [.green, .orange, .red]
            return inverseRange ? colors.reversed() : colors
        }
        
        var body: some View {
            SwiftUI
                .Gauge(value: value) {
                    Text(title)
                } currentValueLabel: {
                    Text("\(value * 100, specifier: "%.0f")%")
                        .foregroundColor(color)
                }
                .gaugeStyle(.accessoryCircular)
                .tint(Gradient(colors: gradientColors))
        }
        
        private var color: Color {
            gradientColors.interpolated(at: CGFloat(value))
        }
    }
}

struct Gauge_Previews: PreviewProvider {
    static var previews: some View {
        Grid {
            GridRow {
                Metrics.Metric.Gauge(title: "CPU", value: 0.4)
                Metrics.Metric.Gauge(title: "MEM", value: 0.73)
            }
            GridRow {
                Metrics.Metric.Gauge(title: "BAT", value: 0.98, inverseRange: true)
            }
        }
    }
}
