//
//  ImageScan.swift
//  Drummit
//
//  Created by Max Brayman on 10/2/26.
//

import Foundation
import SwiftData
import UIKit

@Model
final class ImageScan {
    var title: String
    var dateScanned: Date
    @Attribute(.externalStorage) var imageData: Data?
    @Relationship(deleteRule: .nullify, inverse: \ImageScanItem.scan)
    var items: [ImageScanItem]
    
    var uiImage: UIImage? {
        if let data = imageData {
            return UIImage(data: data)
        }
        return nil
    }
    
    init(
        title: String,
        dateScanned: Date,
        imageData: Data? = nil,
        items: [ImageScanItem]
    ) {
        self.title = title
        self.dateScanned = dateScanned
        self.imageData = imageData
        self.items = items
    }
    
    convenience init(dto: ImageDetectionResponseDTO, imageData: Data? = nil) {
        let title = dto.title
        let items = dto.items.map { ImageScanItem(dto: $0) }
        
        self.init(
            title: title,
            dateScanned: dto.dateScanned,
            imageData: imageData,
            items: items
        )
    }
}

extension ImageScan {
    static var samples: [ImageScan] {
        let imageOne = UIImage(named: "testImage1")
        let imageDataOne = imageOne?.jpegData(compressionQuality: 0.8)
        
        let imageTwo = UIImage(named: "testImage2")
        let imageDataTwo = imageTwo?.jpegData(compressionQuality: 0.8)
        
        let kit = ImageScan(
            title: "Rehearsal room kit", dateScanned: Calendar.current.date(byAdding: .day, value: -8, to: .now)!,
            imageData: imageDataOne,
            items: [
                ImageScanItem(
                    equipment: Equipment(brand: "Zildjian", model: "A Custom",
                                         kind: .cymbal(type: .ride, size: 22)),
                    bounds: ItemBounds(x: 56, y: 640, width: 592 - 56, height: 942 - 640),
                    confidence: ScanConfidence(level: .medium, explanation: "Size is estimated due to the logo being slightly blurry")
                ),
                ImageScanItem(
                    equipment: Equipment(brand: "Vic Firth", model: "5B", kind: .stick(type: .wood)),
                    bounds: ItemBounds(x: 400, y: 340, width: 592 - 56, height: 942 - 640),
                    confidence: ScanConfidence(level: .high, explanation: "Brand and model logos are clearly visible")
                )
            ]
        )
        
        let studioSession = ImageScan(
            title: "Recording studio session kit", dateScanned: .now,
            imageData: imageDataTwo,
            items: [
                ImageScanItem(
                    equipment: Equipment(brand: "Zildjian", model: "A Custom",
                                         kind: .cymbal(type: .ride, size: 22)),
                    bounds: ItemBounds(x: 56, y: 640, width: 592 - 56, height: 942 - 640),
                    confidence: ScanConfidence(level: .medium, explanation: "Size is estimated due to the logo being slightly blurry")
                ),
                ImageScanItem(
                    equipment: Equipment(brand: "Vic Firth", model: "5B", kind: .stick(type: .wood)),
                    bounds: ItemBounds(x: 400, y: 340, width: 592 - 56, height: 942 - 640),
                    confidence: ScanConfidence(level: .high, explanation: "Brand and model logos are clearly visible")
                )
            ]
        )
        
        let cymbalShelves = ImageScan(
            title: "Shelves of assorted cymbals", dateScanned: Calendar.current.date(byAdding: .day, value: -12, to: .now)!,
            imageData: nil,
            items: [
                ImageScanItem(
                    equipment: Equipment(brand: "Zildjian", model: "Constantinople",
                                         kind: .cymbal(type: .crash, size: 18)),
                    bounds: ItemBounds(x: 400, y: 340, width: 592 - 56, height: 942 - 640),
                    confidence: ScanConfidence(level: .medium, explanation: "Size is estimated due to the logo being slightly blurry")
                ),
                ImageScanItem(
                    equipment: Equipment(brand: "Meinl", model: "Byzance Foundry Reserve",
                                         kind: .cymbal(type: .ride, size: 22)),
                    bounds: ItemBounds(x: 56, y: 640, width: 592 - 56, height: 942 - 640),
                    confidence: ScanConfidence(level: .medium, explanation: "Size is estimated due to the logo being slightly blurry")
                )
            ]
        )
        return [kit, studioSession, cymbalShelves]
    }
}
