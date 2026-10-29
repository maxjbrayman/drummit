//
//  AppButtonStyle.swift
//  Drummit
//
//  Created by Max Brayman on 10/13/26.
//

import SwiftUI

enum AppButtonStyleOption {
    case primary
    case outline
}

struct AppButtonStyle: ButtonStyle {
    let style: AppButtonStyleOption
    var tint: Color = .brandPrimary
    
    func makeBody(configuration: Configuration) -> some View {
        AppButton(configuration: configuration, style: style, tint: tint)
    }
    
    private struct AppButton: View {
        let configuration: Configuration
        let style: AppButtonStyleOption
        let tint: Color
        private let cornerRadius: CGFloat = CornerRadius.lg
        
        @Environment(\.isEnabled) private var isEnabled
        
        private var adjustedTint: Color {
            isEnabled ? tint : tint.opacity(0.6)
        }
        
        private var background: Color {
            switch style {
            case .primary:
                    adjustedTint
            case .outline:
                    .white
            }
        }
        
        private var textColor: Color {
            switch style {
            case .primary:
                    .white
            case .outline:
                    adjustedTint
            }
        }
        
        var body: some View {
            configuration.label
                .buttonStyle(.plain)
                .foregroundStyle(textColor)
                .frame(maxWidth: .infinity)
                .padding()
                .bold()
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius).fill(background)
                )
                .overlay {
                    if style == .outline {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .strokeBorder(adjustedTint, lineWidth: 2)
                    }
                }
                .contentShape(RoundedRectangle(cornerRadius: cornerRadius))
                .opacity(configuration.isPressed ? 0.7 : 1)
        }
    }
}

extension ButtonStyle where Self == AppButtonStyle {
    static func app(_ style: AppButtonStyleOption, tint: Color = .brandPrimary) -> AppButtonStyle {
        AppButtonStyle(style: style, tint: tint)
    }
}
