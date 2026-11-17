//
//  ScanDetailsItems.swift
//  Drummit
//
//  Created by Max Brayman on 10/19/26.
//

import SwiftUI

struct ScanItemCard<RightContent: View>: View {
    let item: ImageScanItem
    var number: Int? = nil
    @ViewBuilder let rightContent: () -> RightContent
    
    private let numberCircleSize: CGFloat = 32.5
    
    private var description: String? {
        var terms: [String] = []
        
        if let equipmentDescription = item.equipment.displayDescription {
            terms.append(equipmentDescription)
        }
        
        if let confidenceLevel = item.confidence?.level {
            terms.append(confidenceLevel.displayText)
        }
        
        if terms.isEmpty { return nil }
        
        return terms.joined(separator: " · ")
        
    }
    
    var body: some View {
        HStack {
            if let number {
                Text("\(number)")
                    .bold()
                    // Fixed, not adaptive: the amber circle is bright in both
                    // modes, so the number must stay dark to be readable.
                    .foregroundStyle(.black)
                    .frame(width: numberCircleSize, height: numberCircleSize)
                    .background(.brandAccent)
                    .clipShape(Circle())
            }
            VStack(alignment: .leading) {
                Text(item.equipment.displayTitle)
                    .font(.system(size: 18))
                    .bold()
                    .lineLimit(2)
                if let description {
                    Text(description)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            rightContent()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

extension ScanItemCard where RightContent == EmptyView {
    init(item: ImageScanItem, number: Int? = nil) {
        self.init(item: item, number: number) {
            EmptyView()
        }
    }
}

#Preview {
    let items = [
        ImageScanItem(
            equipment: Equipment(
                brand: "Sabian",
                model: "AAX X-Plosion",
                kind: .cymbal(type: .crash, size: 19)
            ),
            bounds: ItemBounds(x: 0, y: 0, width: 0, height: 0),
            confidence: ScanConfidence(level: .medium, explanation: nil)
        ),
        ImageScanItem(
            equipment: Equipment(
                brand: "Sabian",
                model: "AAX X-Plosion",
                kind: .cymbal(type: .crash, size: 19)
            ),
            bounds: ItemBounds(x: 0, y: 0, width: 0, height: 0),
            confidence: ScanConfidence(level: .medium, explanation: nil)
        )
    ]
    ScanItemCard(item: items[0], number: 1) {
        Image(systemName: "chevron.right")
    }
        .padding(14)
        .border(.black)
}
