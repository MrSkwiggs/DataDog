//
//  MetricThresholdRange.swift
//
//  Created by Dorian Grolaux on 21/09/2022.
//

import Foundation

/// Represents how a metric should treat the range of valid values with regards to its threshold
///
/// The default representation considers the `lower` range of values as valid (that is, values numerically _under_ the threshold).
/// Therefore, `MetricBoundaryEvent.exceeded` events are emitted when the metric increases, and goes numerically _above_ its threshold.
///
/// Inversely, the `upper` representation treats values as valid if they are numerically _above_ the threshold.
/// That is, `MetricThresholdState.critical` events are emitted when the metric decreases, and goes numerically _under_ its threshold
public enum MetricThresholdRange: Codable {
    /// Defines the range of values considered as `nominal` as the values numerically inferior to a metric's threshold
    ///
    /// `0 <= nominal values < threshold <= exceeding values <= 1`
    case lower
    
    /// Defines the range of values considered as `nominal` as the values numerically superior to a metric's threshold
    ///
    /// `0 <= exceeding values <= threshold < nominal values <= 1`
    case upper
}

public extension MetricThresholdRange {
    /// Computes the threshold state from the given metric & threshold values.
    func mapToState(_ metric: Float, on Limits: MetricProviderUseCase.Type, threshold: Float) -> MetricThresholdState {
        let range = Limits.maxValue - Limits.minValue
        let correctedStartValue = metric - Limits.minValue
        let percentage = correctedStartValue / range
        
        switch self {
        case .lower:
            guard Limits.minValue <= metric && metric < threshold * Limits.maxValue else {
                return .critical(value: metric, percentage: percentage)
            }
            
            return .nominal(value: metric, percentage: percentage)
            
        case .upper:
            guard threshold * Limits.maxValue < metric && metric <= Limits.maxValue else {
                return .critical(value: metric, percentage: percentage)
            }
            
            return .nominal(value: metric, percentage: percentage)
        }
    }
}
