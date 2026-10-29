//
//  ImageScanStore.swift
//  Drummit
//
//  Created by Max Brayman on 10/16/26.
//

import Observation
import Foundation
import SwiftData

@Observable
final class ImageScanStore {
    let service: ImageScanServiceImplementation
    let context: ModelContext
    
    init(service: ImageScanServiceImplementation, context: ModelContext) {
        self.service = service
        self.context = context
    }
    
    func scanImage(_ imageData: Data, fileName: String) async throws -> ImageDetectionResponseDTO {
        try await service.scanImage(
            imageData,
            fileName: fileName
        )
    }
    
    func deleteScan(_ scan: ImageScan) {
        context.delete(scan)
    }
    
    func save(_ scan: ImageScan) {
        context.insert(scan)
    }
}
