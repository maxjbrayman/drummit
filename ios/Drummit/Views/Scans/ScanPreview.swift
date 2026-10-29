//
//  ScanPreview.swift
//  Drummit
//
//  Created by Max Brayman on 10/13/26.
//

import SwiftUI

struct ScanPreview: View {
    let scan: ImageScan
    
    private var scanDescriptionText: String {
        "\(scan.items.count) items - \(scan.dateScanned.formatted(.dateTime.month(.abbreviated).day()))"
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            imageView
            Text(scan.title)
                .frame(alignment: .leading)
                .bold()
                .lineLimit(1)
            Text(scanDescriptionText)
                .font(.system(size: 14))
        }
        .frame(alignment: .leading)
    }
    
    @ViewBuilder private var imageView: some View {
        Color.clear
            .aspectRatio(1, contentMode: .fill)
            .overlay {
                if let image = scan.uiImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image(systemName: "photo.badge.exclamationmark")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.thickMaterial)
                        .font(.system(size: 24))
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
    }
}
