//
//  ScannedImage.swift
//  Drummit
//
//  Created by Max Brayman on 10/16/26.
//

import SwiftUI
import SwiftData

struct ScannedImage: View {
    let scan: ImageScan
    @Binding var selectedItemId: UUID?
    private let numberSize: CGFloat = 20
    
    private func getInterpolatedBounds(bounds: ItemBounds, proxy: GeometryProxy) -> ItemBounds {
        let fromRange = (bounds.scale[0], bounds.scale[1])
        let offsetX = MathUtils.interpolate(value: bounds.x, from: fromRange, to: (0, proxy.size.width))
        let offsetY = MathUtils.interpolate(value: bounds.y, from: fromRange, to: (0, proxy.size.height))
        let width = MathUtils.interpolate(value: bounds.width, from: fromRange, to: (0, proxy.size.width))
        let height = MathUtils.interpolate(value: bounds.height, from: fromRange, to: (0, proxy.size.height))
        
        return ItemBounds(x: offsetX, y: offsetY, width: width, height: height)
    }
    
    private var img: Image? {
        if let uiImage = scan.uiImage {
            return Image(uiImage: uiImage)
        }
        
        return nil
    }
    
    var body: some View {
        if let img {
            img
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .overlay(alignment: .topLeading) {
                    GeometryReader { proxy in
                        ForEach(
                            scan.items.enumerated(),
                            id: \.element.uuid) { (index, item) in
                            let bounds = getInterpolatedBounds(
                                bounds: item.bounds,
                                proxy: proxy
                            )
                                
                            let color = Color.brandAccent.opacity(
                                selectedItemId == nil || selectedItemId == item.uuid ? 1 : 0.5
                            )
                                
                                let numberX: CGFloat = min(
                                    max(bounds.x - numberSize / 2, 0),
                                    proxy.size.width - numberSize
                                )
                                
                                let numberY: CGFloat = min(
                                    max(bounds.y - numberSize / 2, 0),
                                    proxy.size.height - numberSize
                                )
                            
                            ZStack(alignment: .topLeading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .strokeBorder(
                                        color,
                                        lineWidth: 2
                                    )
                                    .frame(width: bounds.width, height: bounds.height)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        selectedItemId = item.uuid
                                    }
                                    .offset(x: bounds.x, y: bounds.y)
                                Text("\(index + 1)")
                                    .frame(width: numberSize, height: numberSize)
                                    .background(color, in: Circle())
                                    .foregroundStyle(.black)
                                    .font(.system(size: 14))
                                    .offset(
                                        x: numberX,
                                        y: numberY
                                    )
                                    .bold()
                            }
                        }
                    }
                }
        } else {
            Image(systemName: "photo.badge.exclamationmark")
                .frame(maxWidth: .infinity)
                .frame(height: 200)
                .background(.gray.opacity(0.2))
                .font(.system(size: 38))
        }
    }
}

#Preview {
    @Previewable @State var selectedId: UUID? = nil
    ScannedImage(
        scan: ImageScan.samples[0],
        selectedItemId: $selectedId)
}
