//
//  BrandedButtonStyle .swift
//  DataDogApp
//
//  Created by Dorian Grolaux on 25/09/2022.
//

import SwiftUI

struct BrandedButtonStyle: ButtonStyle {
    
    let appearance: Appearance
    
    @Environment(\.isEnabled)
    private var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .semibold))
            .frame(maxWidth: appearance.fullWidth ? .infinity : nil)
            .padding(appearance.padding)
            .background(appearance.backgroundColor(isEnabled: isEnabled))
            .foregroundColor(appearance.titleColor(isEnabled: isEnabled))
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .shadow(color: isEnabled ? appearance.shadowColor : .clear,
                    radius: configuration.isPressed ? 1 : 3,
                    x: 0,
                    y: configuration.isPressed ? 1 : 3)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

extension BrandedButtonStyle {
    struct Appearance {
        enum Style {
            case regular
            case transparent
        }
        
        let style: Style
        let accentColor: Color
        
        func titleColor(isEnabled: Bool) -> Color {
            switch style {
            case .regular:
                return .ui(.background)
            case .transparent:
                return isEnabled ? accentColor : .ui(.disabled)
            }
        }
        
        func backgroundColor(isEnabled: Bool) -> Color {
            switch style {
            case .regular:
                return isEnabled ? accentColor : .ui(.disabled)
            case .transparent:
                return .clear
            }
        }
        
        var shadowColor: Color {
            switch style {
            case .regular:
                return .ui(.shadow)
            case .transparent:
                return .clear
            }
        }
        
        var fullWidth: Bool {
            switch style {
            case .regular:
                return true
            case .transparent:
                return false
            }
        }
        
        var padding: CGFloat {
            switch style {
            case .regular:
                return 16
            case .transparent:
                return 0
            }
        }
        
        static let regular = Appearance(style: .regular, accentColor: .ui(.accent))
        static let transparent = Appearance(style: .transparent, accentColor: .text())
        
        func `in`(_ color: Color) -> Self {
            .init(style: style, accentColor: color)
        }
    }
}

extension Button {
    var branded: some View {
        self.buttonStyle(BrandedButtonStyle(appearance: .regular))
    }
    
    func branded(_ appearance: BrandedButtonStyle.Appearance) -> some View {
        self.buttonStyle(BrandedButtonStyle(appearance: appearance))
    }
}

struct RegularButtonStyle_Previews: PreviewProvider {
    static var previews: some View {
        Button {
            //
        } label: {
            Text("Press me")
                .bold()
        }
        .branded
        .padding()
        .previewLayout(.sizeThatFits)
    }
}

