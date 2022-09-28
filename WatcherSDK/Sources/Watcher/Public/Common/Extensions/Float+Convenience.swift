//
//  Float+Convenience.swift
//  
//
//  Created by Dorian Grolaux on 28/09/2022.
//

import Foundation

public extension Float {
    /// Calculates where this value stands within the range of given min & max values and returns it as a percentage.
    ///
    /// - parameters:
    ///  - minValue: The lower bound of the range
    ///  - maxValue: The upper bound of the range
    /// - returns: This value as a percentage of the given range. If this value is below the given `minValue`, returns a negative number. If it is above `maxValue`, returns a number greater than `1.0`.
    func expressedAsPercentage(ofMinValue minValue: Float, maxValue: Float) -> Float {
        let range = maxValue - minValue
        let correctedStartValue = self - minValue
        return correctedStartValue / range
    }
}
