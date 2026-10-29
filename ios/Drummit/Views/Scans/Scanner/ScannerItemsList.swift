//
//  ScannerItemsList.swift
//  Drummit
//
//  Created by Max Brayman on 10/23/26.
//

import SwiftUI

struct ScannerItemsList<Destination: Hashable>: View {
    let items: [ImageScanItem]
    var selectedItemId: UUID? = nil
    let navigationDestination: (ImageScanItem) -> Destination
    
    private var selectedItem: (Int, ImageScanItem)? {
        guard let selectedItemId else { return nil }
        
        guard let index = items.firstIndex(where: {
            $0.uuid == selectedItemId
        }) else { return nil }
        
        return (index, items[index])
    }
    
    var body: some View {
        if !items.isEmpty {
            VStack {
                if let (index, item) = selectedItem {
                    NavigationLink(
                        value: navigationDestination(item)
                    ) {
                        ScanItemCard(item: item, number: index + 1) {
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.tertiary)
                                .font(.footnote.weight(.bold))
                        }
                    }
                    .buttonStyle(.plain)
                } else {
                    ForEach(items.enumerated(), id: \.element.uuid) { (index, item) in
                        NavigationLink(value: navigationDestination(item)) {
                            ScanItemCard(item: item, number: index + 1) {
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.tertiary)
                                    .font(.footnote.weight(.bold))
                            }
                        }
                        .buttonStyle(.plain)
                        if index < items.count - 1 { Divider() }
                    }
                }
            }
            .navigationLinkIndicatorVisibility(.hidden)
            .padding(.vertical)
            .padding(.horizontal, Spacing.sm)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
        }
    }
}
