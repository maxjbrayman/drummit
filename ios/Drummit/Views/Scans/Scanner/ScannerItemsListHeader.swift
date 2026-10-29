//
//  ScannerItemsListHeader.swift
//  Drummit
//
//  Created by Max Brayman on 10/28/26.
//

import SwiftUI

struct ScannerItemsListHeader: View {
    let itemsCount: Int
    @Binding var selectedItemId: UUID?
    var showItemsCount = true
    var body: some View {
        HStack {
            if showItemsCount {
                Text("\(itemsCount) items found")
            }
            Spacer()
            if selectedItemId != nil {
                Button("View all") {
                    selectedItemId = nil
                }
            }
        }
    }
}
