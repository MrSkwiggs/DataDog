//
//  ThresholdEditor.swift
//  DataDogApp
//
//  Created by Dorian Grolaux on 25/09/2022.
//

import SwiftUI
import Watcher

struct ThresholdEditor: View {
    
    private let initialValue: Float
    
    @Binding
    var threshold: Float
    
    let metricType: MetricType
    
    private let formatter: Formatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        return formatter
    }()
    
    let completion: () -> Void
    
    init(threshold: Binding<Float>,
         metricType: MetricType,
         completion: @escaping () -> Void) {
        self._threshold = threshold
        self.metricType = metricType
        self.completion = completion
        self.initialValue = threshold.wrappedValue
    }
    
    
    var body: some View {
        VStack(spacing: 25) {
            Capsule()
                .fill(Color.ui(.disabled))
                .frame(width: 50,
                       height: 8)
            HStack {
                VStack(alignment: .leading) {
                    Text("Edit threshold")
                        .font(.largeTitle)
                    Text("Set the desired threshold for ")
                        .font(.subheadline)
                    + Text(metricType.description)
                        .font(.subheadline)
                        .bold()
                }
                Spacer()
            }
            HStack {
                Text("Threshold: ")
                TextField("", value: $threshold, formatter: formatter)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.decimalPad)
            }
            
            Spacer()
            
            Slider(value: $threshold, in: 0.0...1.0, step: 0.01)
            VStack {
                Button {
                    completion()
                } label: {
                    Text("Submit")
                }
                .branded(.regular)
                
                Button {
                    threshold = initialValue
                    completion()
                } label: {
                    Text("Cancel")
                        .padding()
                }
                .branded(.transparent.in(.ui(.danger)))

            }
        }
        .padding()
    }
}

struct ThresholdConfigurator_Previews: PreviewProvider {
    static var previews: some View {
        ThresholdEditor(threshold: .constant(0.3),
                              metricType: .cpu) {
            //
        }
        .previewLayout(.sizeThatFits)
    }
}
