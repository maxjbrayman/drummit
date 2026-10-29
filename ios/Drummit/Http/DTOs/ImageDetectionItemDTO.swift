//
//  ImageDetectionItemDTO.swift
//  Drummit
//
//  Created by Max Brayman on 10/15/26.
//

struct ImageDetectionItemDTO: Decodable {
    let type: String
    let subtype: String?
    let brand: String?
    let model: String?
    let diameter: Int?
    let depth: Int?
    let confidenceLevel: String
    let confidenceExplanation: String?
    let improvementSuggestions: [String]
    let box2D: [Int]
}
