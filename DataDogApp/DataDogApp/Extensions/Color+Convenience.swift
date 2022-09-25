//
//  Color+Convenience.swift
//  DataDogApp
//
//  Created by Dorian Grolaux on 25/09/2022.
//

import SwiftUI

extension Array where Element == Color {
    /// Returns an interpolated color from the given percentage
    func interpolated(at percentage: CGFloat) -> Color {
        switch percentage {
        case 0: return first ?? .clear
        case 1: return last ?? .clear
            
        default:
            let approxIndex = percentage / (1 / CGFloat(count - 1))
            let firstIndex = Int(approxIndex.rounded(.down))
            let secondIndex = Int(approxIndex.rounded(.up))
            let fallbackIndex = Int(approxIndex.rounded())
            
            let firstColor = UIColor(self[firstIndex])
            let secondColor = UIColor(self[secondIndex])
            let fallbackColor = self[fallbackIndex]
            
            var (r1, g1, b1, a1): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
            var (r2, g2, b2, a2): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
            guard firstColor.getRed(&r1, green: &g1, blue: &b1, alpha: &a1) else { return fallbackColor }
            guard secondColor.getRed(&r2, green: &g2, blue: &b2, alpha: &a2) else { return fallbackColor }
            
            let intermediatePercentage = approxIndex - CGFloat(firstIndex)
            return Color(UIColor(red: CGFloat(r1 + (r2 - r1) * intermediatePercentage),
                                 green: CGFloat(g1 + (g2 - g1) * intermediatePercentage),
                                 blue: CGFloat(b1 + (b2 - b1) * intermediatePercentage),
                                 alpha: CGFloat(a1 + (a2 - a1) * intermediatePercentage)))
        }
    }
}
