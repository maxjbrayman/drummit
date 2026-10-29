//
//  ScanningOverlay.swift
//  Drummit
//
//  Created by Max Brayman on 10/23/26.
//

import SwiftUI

struct ScanningOverlay: View {
    @State private var scanBarOffsetY: CGFloat = 0
    private var animation: Animation {
        .linear
        .speed(0.2)
        .repeatForever(autoreverses: true)
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
            GeometryReader { proxy in
                RoundedRectangle(cornerRadius: CornerRadius.sm).fill(.brandAccent)
                    .frame(height: 4)
                    .padding(.horizontal, Spacing.xs)
                    .shadow(color: .brandAccent, radius: 10)
                    .offset(y: scanBarOffsetY)
                    .onAppear {
                        withAnimation(animation) {
                            scanBarOffsetY = proxy.size.height
                        }
                    }
            }
            CornerBrackets()
                .stroke(.white, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .padding(Spacing.xs)
        }
    }
}
