//
//  ImageDetectionService.swift
//  Drummit
//
//  Created by Max Brayman on 10/15/26.
//

import Foundation

protocol ImageScanServiceImplementation {
    func scanImage(_ imageData: Data, fileName: String) async throws -> ImageDetectionResponseDTO
}

struct ImageScanService: ImageScanServiceImplementation {
    let client: Client
    
    func scanImage(_ imageData: Data, fileName: String = "image.jpeg") async throws -> ImageDetectionResponseDTO {
        let formDataManager = MultipartFormDataManager()
        let (body, contentTypeHeader) = formDataManager.getBodyAndHeader(
            formData: [FormDataEntry(key: "image", value: .fileType(contentType: "image/jpeg", fileName: fileName, data: imageData))]
        )
        
        return try await client.post(
            path: "/detection",
            payload: body,
            params: nil,
            headers: ["Content-Type" : contentTypeHeader]
        )
    }
}
