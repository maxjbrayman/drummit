//
//  MyGearItemCard.swift
//  Drummit
//
//  Created by Max Brayman on 10/2/26.
//

import SwiftUI

struct MyGearItemCard: View {
    let title: String
    var description: String? = nil
    var image: Image? = nil
    
    private let cardSize: CGFloat = 60
    
    var body: some View {
        HStack(alignment: .top) {
            if let image {
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: cardSize, height: cardSize)
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
            } else {
                Image(systemName: "photo.badge.exclamationmark")
                    .frame(width: cardSize, height: cardSize)
                    .background(.ultraThickMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
            }
            VStack(alignment: .leading) {
                Text(title)
                    .font(.title3)
                    .bold()
                    .lineLimit(1)
                if let description {
                    Text(description)
                        .font(.subheadline)
                        .lineLimit(1)                    
                }
            }
        }
        .frame(height: cardSize)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

extension MyGearItemCard {
    init(title: String, description: String? = nil, uiImage: UIImage?) {
        self.title = title
        self.description = description
        if let uiImage {
            self.image = Image(uiImage: uiImage)
        }
    }
}

extension MyGearItemCard {
    init(title: String, description: String? = nil, imageData: Data?) {
        self.title = title
        self.description = description
        if let imageData, let uiImage = UIImage(data: imageData) {
            self.image = Image(uiImage: uiImage)
        }
    }
}

#Preview {
    MyGearItemCard(title: "Zildjian A Custom Medium Ride", description: "22 in - Rehearsal Room Kit")
}
