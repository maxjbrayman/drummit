//
//  Color+Semantic.swift
//  Drummit
//

import SwiftUI

/// App-wide surface colors that adapt to light and dark mode.
///
/// SwiftUI doesn't expose UIKit's background colors directly, so these wrap
/// them with names that describe what each one is for. Declaring them on
/// `ShapeStyle where Self == Color` makes the short dot syntax work anywhere
/// a color or style is expected: `.background(.cardBackground)`,
/// `.fill(.cardBackground)`, and `Color.cardBackground` all compile.
extension ShapeStyle where Self == Color {
    /// The background of a whole screen: white in light mode, black in dark
    /// mode (slightly lifted inside sheets).
    static var screenBackground: Color {
        Color(uiColor: .systemBackground)
    }

    /// A raised surface on top of the screen background, such as a card:
    /// white in light mode (so cards look the same as before) and dark gray
    /// in dark mode, so it stands out from the black screen behind it.
    static var cardBackground: Color {
        Color(uiColor: .secondarySystemGroupedBackground)
    }
}
