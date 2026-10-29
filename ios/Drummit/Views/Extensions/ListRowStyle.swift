//
//  ListRowStyle.swift
//  Drummit
//
//  Created by Max Brayman on 10/13/26.
//

import SwiftUI

enum ListRowStyleOption {
    case none
    case initial
}

struct ListRowStyle: ViewModifier {
    let style: ListRowStyleOption
    func body(content: Content) -> some View {
        content
            .listRowBackground(style == .none ? Color.clear : nil)
            .listRowInsets(style == .none ? EdgeInsets() : nil)
            .listRowSeparator(style == .none ? .hidden : .automatic)
    }
}

extension View {
    func listRowStyle(_ style: ListRowStyleOption) -> some View {
        modifier(ListRowStyle(style: style))
    }
}
