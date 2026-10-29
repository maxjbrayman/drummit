//
//  ScrollViewCollapsingHeader.swift
//  Drummit
//
//  Created by Max Brayman on 10/24/26.
//

import SwiftUI

struct GeoScroll: Equatable {
    let offsetY: CGFloat
    let maxOffsetY: CGFloat
    var topInset: CGFloat = 0
}

enum CollapsedPercentage {
    case full
    case safeArea
    case percentage(CGFloat)
}

struct ScrollViewCollapsingHeader<Content: View, Header: View>: View {
    var collapsedPercentage: CollapsedPercentage = .percentage(50)
    var headerBackground = AnyShapeStyle(.bar)
    @ViewBuilder let header: (CGFloat) -> Header
    @ViewBuilder let content: () -> Content
    
    @State private var headerHeight: CGFloat = 0
    @State private var offsetY: CGFloat = 0
    
    private var progress: CGFloat {
        let fromLeft: CGFloat = 0
        let fromRight = switch collapsedPercentage {
        case .full, .safeArea: headerHeight
        case .percentage(let percentage):
            headerHeight * (percentage / 100)
        }
        let value = MathUtils.interpolate(value: offsetY, from: (fromLeft, fromRight), to: (0, 1))
        if value.isNaN { return 0 }
        return value
    }
    
    var body: some View {
        ScrollView {
            content()
        }
        .onScrollGeometryChange(
            for: GeoScroll.self,
            of: { geo in
                GeoScroll(
                    offsetY: geo.contentOffset.y + geo.contentInsets.top,
                    maxOffsetY: geo.contentSize.height - geo.containerSize.height,
                    topInset: geo.contentInsets.top
                )
            }, action: onScroll)
        
        .safeAreaInset(edge: .top) {
            header(progress)
                .frame(maxWidth: .infinity)
                .onGeometryChange(for: CGFloat.self, of: {
                    $0.size.height
                }) {
                    headerHeight = $0
                }
                .background(headerBackground, ignoresSafeAreaEdges: .top)
                .offset(y: -offsetY)
        }
    }
    
    private func onScroll(_ oldValue: GeoScroll, _ newValue: GeoScroll) {
        if newValue.offsetY < 0 || newValue.offsetY >= newValue.maxOffsetY { return }
        let increment = newValue.offsetY - oldValue.offsetY
        
        let maxClamp = switch collapsedPercentage {
        case .full:
            newValue.topInset
        case .safeArea:
            headerHeight
        case .percentage(let percentage):
            headerHeight * (percentage / 100)
        }
        
        offsetY = MathUtils
            .clamp(
                offsetY + increment,
                min: 0,
                max: maxClamp
            )
    }
}

extension ScrollViewCollapsingHeader {
    func headerBackground(_ style: some ShapeStyle) -> Self {
        var copy = self
        copy.headerBackground = AnyShapeStyle(style)
        return copy
    }
}

#Preview {
    @Previewable @State var collapsed = false
    @Previewable @Namespace var animation
    @Previewable @Namespace var headerTransition
    ScrollViewCollapsingHeader(header: { progress in
        let collapsed = progress > 0.5
        return HStack {
            HStack(alignment: .bottom) {
                if !collapsed {
                    Text("Hello")
                        .matchedGeometryEffect(id: headerTransition, in: animation)
                        .padding(.leading)
                        .scaleEffect(2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    Text("Hello")
                        .matchedGeometryEffect(id: headerTransition, in: animation)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                        .padding(.bottom)
                }
            }
            .animation(.easeInOut, value: collapsed)
            .frame(height: 150)
        }
    }) {
        ForEach(0..<100, id: \.self) { index in
            Text("\(index)")
        }
        .frame(maxWidth: .infinity)
    }
    .headerBackground(.ultraThickMaterial)
//    .ignoresSafeArea()
}
