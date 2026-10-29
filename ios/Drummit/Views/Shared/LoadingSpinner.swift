//
//  LoadingSpinner.swift
//  Drummit
//
//  Created by Max Brayman on 10/23/26.
//

import SwiftUI

struct LoadingSpinner: View {
    var color: Color = .brandAccent
    var size: CGFloat = 25
    var thickness: CGFloat = 4
    var speed: CGFloat = 0.3
    
    @State private var rotation: CGFloat = 0
    private var animation: Animation {
        .linear
        .speed(speed)
        .repeatForever(autoreverses: false)
    }
    
    var body: some View {
        Circle()
            .trim(from: 0, to: 0.8)
            .stroke(color, lineWidth: thickness)
            .rotationEffect(.degrees(rotation))
            .frame(width: size, height: size)
            .onAppear() {
                withAnimation(animation) {
                    rotation = 360
                }
            }
    }
}

#Preview {
    LoadingSpinner()
}
