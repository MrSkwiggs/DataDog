//
//  Range+Convenience.swift
//  DataDogApp
//
//  Created by Dorian Grolaux on 21/09/2022.
//

import Foundation

extension ClosedRange {
    /// Returns the given value if it is contained with the range bounds, or the closest bound otherwise.
    func clamping(_ value: Bound) -> Bound {
        lowerBound > value
            ? lowerBound
            : upperBound < value
                ? upperBound
                : value
    }
}
