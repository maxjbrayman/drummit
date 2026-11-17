//
//  TapOnlyButtonStyle.swift
//  Drummit
//

import SwiftUI

/// A button style that fires only on a genuine tap.
///
/// A normal button fires when the finger lifts while still over it. Inside a
/// ScrollView in a sheet, a drag doesn't always cancel the button (part of
/// the drag can go to the sheet or the scroll bounce instead), so dragging,
/// pausing and lifting over a row can trigger it. This style triggers through
/// a TapGesture, which fails as soon as the finger moves, so any drag is
/// ignored.
///
/// It is a PrimitiveButtonStyle rather than a ButtonStyle because only a
/// primitive style decides *when* the button's action runs.
struct TapOnlyButtonStyle: PrimitiveButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            // Make the whole row tappable, including empty space between
            // the text and the chevron, as a plain button would be.
            .contentShape(Rectangle())
            .onTapGesture {
                configuration.trigger()
            }
            // The tap gesture replaces the button's built-in behaviour, so
            // keep it announced and usable as a button for VoiceOver.
            .accessibilityAddTraits(.isButton)
            .accessibilityAction {
                configuration.trigger()
            }
    }
}

extension PrimitiveButtonStyle where Self == TapOnlyButtonStyle {
    /// A style that fires only on a genuine tap, never at the end of a drag.
    static var tapOnly: TapOnlyButtonStyle { TapOnlyButtonStyle() }
}
