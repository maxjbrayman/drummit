//
//  WrappingHStack.swift
//  Drummit
//
//  Created by Max Brayman on 10/26/26.
//

import SwiftUI

struct WrappingHStack: Layout {
    var horizontalSpacing: CGFloat = Spacing.sm
    var verticalSpacing: CGFloat = Spacing.sm
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = computeRows(
            maxWidth: proposal.width ?? .infinity,
            subviews: subviews
        )
        
        let rowsHeight = rows.reduce(0) {
            $0 + $1.height
        }
        let totalSpacing = verticalSpacing * CGFloat(rows.count - 1)
        let totalHeight = rowsHeight + totalSpacing
        
        let width = rows.map {$0.width}.max() ?? .infinity
        
        return CGSize(width: width, height: totalHeight)
    }
    
    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        let rows = computeRows(maxWidth: bounds.width, subviews: subviews)
        var y = bounds.minY
        
        rows.forEach { row in
            var x = bounds.minX
            row.indices.forEach { index in
                let size = subviews[index].sizeThatFits(.unspecified)
                let width = min(size.width, bounds.width)
                subviews[index]
                    .place(
                        at: CGPoint(x: x, y: y + (row.height - size.height) / 2),
                        anchor: .topLeading,
                        proposal: ProposedViewSize(width: width, height: size.height)
                    )
                x += width + horizontalSpacing
            }
            y += row.height + verticalSpacing
        }
    }
    
    private func computeRows(maxWidth: CGFloat, subviews: Subviews) -> [Row] {
        var rows: [Row] = []
        var currentRow = Row()
        
        // loop through all subviews
        for (index, subview) in subviews.enumerated() {
            // get size of subview
            let size = subview.sizeThatFits(.unspecified)
            // calculate the potential width if the current subview was added to the row
            let widthIfAdded = currentRow.indices.isEmpty
            ? size.width
            : currentRow.width + horizontalSpacing + size.width
            
            // if potential width exceeds max width, create new row, do NOT add subview to current row
            if widthIfAdded > maxWidth {
                rows.append(currentRow)
                currentRow = Row()
            }
            
            // update the current row
            currentRow.indices.append(index)
            currentRow.height = max(currentRow.height, size.height)
            currentRow.width = currentRow.indices.isEmpty
            ? size.width
            : currentRow.width + horizontalSpacing + size.width
        }
        
        if !currentRow.indices.isEmpty { rows.append(currentRow) }
        return rows
    }
    
    private struct Row {
        var indices: [Int] = []
        var width: CGFloat = 0
        var height: CGFloat = 0
    }
}
