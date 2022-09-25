//
//  Metrics+Chart.swift
//  DataDogApp
//
//  Created by Dorian Grolaux on 25/09/2022.
//

import SwiftUI
import Watcher

extension Metrics {
    struct Chart: View {
        
        let values: FixedSizeCollection<Float>
        
        var body: some View {
            GeometryReader { reader in
                Path { path in
                    var segmentPosition: CGFloat = 0
                    path.move(to: .zero)
                    path.addLines(values
                        .map({ value in
                            segmentPosition += segmentSize(maxWidth: reader.size.width)
                            return .init(x: segmentPosition,
                                         y: reader.size.height - reader.size.height * CGFloat(value))
                        }))
                }
                .stroke(Color.green)
            }
        }
        
        private func segmentSize(maxWidth: CGFloat) -> CGFloat {
            guard values.maxCount != 0 else { return 0 }
            return maxWidth / CGFloat(values.maxCount)
        }
    }
}

struct Metrics_Chart_Previews: PreviewProvider {
    static var previews: some View {
        Metrics.Chart(values: Mock.chartValues)
        .padding()
        .frame(width: 300, height: 200)
    }
}
