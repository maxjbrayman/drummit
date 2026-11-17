//
//  ScannerSuccessHeader.swift
//  Drummit
//
//  Created by Max Brayman on 10/23/26.
//

import SwiftUI

struct ScannerSuccessHeader: View {
    let itemCount: Int
    @Binding var titleText: String
    
    @FocusState private var isTitleFieldFocused
    
    var body: some View {
        if itemCount == 0 {
            emptyItemsView
        } else {
            VStack(alignment: .center) {
                HStack {
                    Image(systemName: "checkmark")
                    Text(
                        "Scan complete · \(itemCount) \("item".pluralize(count: itemCount)) found"
                    )
                }
                .foregroundStyle(.brandSuccess)
                .bold()
                titleInput
            }
        }
    }
    
    private var emptyItemsView: some View {
        ScannerTitleAndSubtitle(title: "No items were found", subtitle: "Please try a different image.")
    }
    
    private var titleInput: some View {
        HStack {
            TextField("Scan title...", text: $titleText)
                .font(.title)
                .bold()
                .focused($isTitleFieldFocused)
                .submitLabel(.done)
            Spacer()
            if !isTitleFieldFocused {
                Button(action: { isTitleFieldFocused = true }) {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 24))
                        .transition(.opacity)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(Spacing.sm)
        .background(.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
        .overlay {
            if titleText.isEmpty {
                RoundedRectangle(cornerRadius: CornerRadius.md).strokeBorder(.red)
            }
        }
        .shadow(radius: 1.5)
        .contentShape(Rectangle())
        .animation(.easeInOut(duration: 0.2), value: isTitleFieldFocused)
    }
}
