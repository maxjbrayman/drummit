//
//  CapsulePicker.swift
//  Drummit
//
//  Created by Max Brayman on 10/26/26.
//

import SwiftUI

struct CapsulePicker<Item: Identifiable>: View {
    let items: [Item]
    @Binding var selectedItems: Set<Item.ID>
    var tint: Color = .brandPrimary
    let label: (Item) -> String
    
    private func toggleItem(_ item: Item) {
        if selectedItems.contains(item.id) {
            selectedItems.remove(item.id)
        } else {
            selectedItems.insert(item.id)
        }
    }
    
    private func isSelected(_ item: Item) -> Bool {
        selectedItems.contains(item.id)
    }
    
    var body: some View {
        WrappingHStack {
            ForEach(items) { item in
                Button(label(item)) {
                    toggleItem(item)
                }
                .buttonStyle(.plain)
                .bold()
                .padding(.vertical, Spacing.sm)
                .padding(.horizontal, Spacing.md)
                .foregroundStyle(isSelected(item) ? .white : .primary)
                .background(isSelected(item) ? tint : .screenBackground, in: Capsule())
                .overlay {
                    if !isSelected(item) {
                        Capsule()
                            .strokeBorder(
                                Color(uiColor: .separator),
                                lineWidth: 1
                            )
                    }
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var selected = Set<EquipmentCategory.ID>()
    CapsulePicker(
        items: EquipmentCategory.allCases,
        selectedItems: $selected,
        label: { item in
            item.displayName
        }
    )
}
