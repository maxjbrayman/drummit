//
//  ImageScanDTO.swift
//  Drummit
//
//  Created by Max Brayman on 10/15/26.
//

import Foundation

struct ImageDetectionResponseDTO: Decodable {
    let dateScanned: Date
    let title: String
    let items: [ImageDetectionItemDTO]
}
