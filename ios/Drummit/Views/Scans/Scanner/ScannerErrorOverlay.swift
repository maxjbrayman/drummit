//
//  ScannerErrorOverlay.swift
//  Drummit
//
//  Created by Max Brayman on 10/23/26.
//

import SwiftUI

struct ScannerErrorOverlay: View {
    let errorMessage: String
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
            VStack {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundStyle(.white)
                    .font(.system(size: 36))
                Text(errorMessage)
                    .foregroundStyle(.white)
                    .bold()
            }
        }
    }
}
