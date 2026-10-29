//
//  ImageScanItem.swift
//  Drummit
//
//  Created by Max Brayman on 10/12/26.
//

import Foundation
import SwiftData

struct ItemBounds: Codable {
    let x: CGFloat
    let y: CGFloat
    let width: CGFloat
    let height: CGFloat
    let scale: [CGFloat]
    
    init(
        x: CGFloat,
        y: CGFloat,
        width: CGFloat,
        height: CGFloat,
        scale: [CGFloat] = [0, 1000]
    ) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.scale = scale
    }
}

@Model
final class ImageScanItem {
    private(set) var uuid = UUID()
    private var equipmentData: Data = Data()

    var equipment: Equipment {
        get {
            (try? JSONDecoder().decode(Equipment.self, from: equipmentData)) ?? Equipment(
                brand: nil,
                model: nil,
                kind: .other(details: nil)
            )
        }
        set { equipmentData = (try? JSONEncoder().encode(newValue)) ?? Data() }
    }
    
    var bounds: ItemBounds
    var confidence: ScanConfidence?
    var scan: ImageScan?
    var isSaved: Bool = false
    
    init(
        equipment: Equipment,
        bounds: ItemBounds,
        confidence: ScanConfidence? = nil,
        scan: ImageScan? = nil
    ) {
        self.bounds = bounds
        self.confidence = confidence
        self.scan = scan
        self.equipment = equipment
    }
    
    convenience init(dto: ImageDetectionItemDTO) {
        let boxMinY = CGFloat(dto.box2D[0])
        let boxMinX = CGFloat(dto.box2D[1])
        let boxMaxY = CGFloat(dto.box2D[2])
        let boxMaxX = CGFloat(dto.box2D[3])
        
        let boxHeight = boxMaxY - boxMinY
        let boxWidth = boxMaxX - boxMinX
        
        let bounds = ItemBounds(
            x: boxMinX,
            y: boxMinY,
            width: boxWidth,
            height: boxHeight
        )
        
        var equipmentKind: EquipmentKind
        switch dto.type.lowercased() {
        case "cymbal":
            let cymbalType: CymbalType = CymbalType.create(from: dto.subtype)
            var size: Double?
            if let diameter = dto.diameter { size = Double(diameter) }
            equipmentKind = .cymbal(type: cymbalType, size: size)
            
        case "drum":
            let drumType: DrumType = DrumType.create(from: dto.subtype)
            var depth: Double?
            var diameter: Double?
            if let rawDiameter = dto.diameter { diameter = Double(rawDiameter) }
            if let rawDepth = dto.depth { depth = Double(rawDepth) }
            
            equipmentKind =
                .drum(type: drumType, depth: depth, diameter: diameter)
            
        case "stick":
            let stickType = StickType.create(from: dto.subtype)
            equipmentKind = .stick(type: stickType)
            
        case "pedal":
            equipmentKind = .pedal
            
        case "hardware":
            equipmentKind = .hardware(type: nil)
            
        default: equipmentKind = .other(details: nil)
            
        }
        
        let confidence = ScanConfidence(
            level: ConfidenceLevel.create(from: dto.confidenceLevel),
            explanation: dto.confidenceExplanation
        )
        
        let equipment = Equipment(
            brand: dto.brand,
            model: dto.model,
            kind: equipmentKind
        )
        
        self.init(equipment: equipment, bounds: bounds, confidence: confidence)
        
    }
}
