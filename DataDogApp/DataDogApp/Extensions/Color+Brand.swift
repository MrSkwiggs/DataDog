//
//  Color+Brand.swift
//  DataDogApp
//
//  Created by Dorian Grolaux on 25/09/2022.
//

import SwiftUI

extension Color {
    fileprivate enum Asset {
        static let dark = named("Dark")
        static let light = named("Light")
        static let background = named("Background")
        static let highlight = named("Highlight")
        static let disabled = named("Disabled")
        static let shadow = named("Shadow")
        static let textPrimary = named("TextPrimary")
        static let textSecondary = named("TextSecondary")
        static let accent = named("Accent")
        static let danger = named("Danger")
        static let info = named("Info")
        
        enum Gradient {
            static let backgroundStart = named("Background Start")
            static let backgroundEnd = named("Background End")
        }
        
        private static func named(_ colorName: String) -> Color {
            return Color(colorName)
        }
    }
}

extension Color {
    
    enum Text {
        case primary
        case secondary
    }
    
    static func text(_ text: Text = .primary) -> Color {
        switch text {
        case .primary:
            return Asset.textPrimary
        case .secondary:
            return Asset.textSecondary
        }
    }
    
    enum UI {
        case background
        case highlight
        case disabled
        case shadow
        case accent
        case danger
        case info
    }
    
    static func ui(_ ui: UI) -> Color {
        switch ui {
        case .background:
            return Asset.background
        case .highlight:
            return Asset.highlight
        case .disabled:
            return Asset.disabled
        case .shadow:
            return Asset.shadow
        case .accent:
            return Asset.accent
        case .danger:
            return Asset.danger
        case .info:
            return Asset.info
        }
    }
    
    enum Static {
        case light
        case dark
    }
    
    static func `static`(_ static: Static) -> Color {
        switch `static` {
        case .light:
            return Asset.light
        case .dark:
            return Asset.dark
        }
    }
    
    enum Gradient {
        
        case background(Background)
        
        enum Background {
            case start
            case end
        }
    }
    
    static func gradient(_ gradient: Gradient) -> Color {
        switch gradient {
        case .background(let background):
            switch background {
            case .start:
                return Asset.Gradient.backgroundStart
            case .end:
                return Asset.Gradient.backgroundEnd
            }
        }
    }
}
