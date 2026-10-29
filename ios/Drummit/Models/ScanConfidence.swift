//
//  ScanConfidence.swift
//  Drummit
//
//  Created by Max Brayman on 10/1/26.
//

enum ConfidenceLevel: Codable {
    case low
    case medium
    case high
    
    var displayText: String {
        switch self {
        case .low:
            "Low confidence"
        case .medium:
            "Medium confidence"
        case .high:
            "High confidence"
        }
    }
    
    static func create(from string: String?) -> ConfidenceLevel {
        switch string?.lowercaseAndStripSeparators() {
        case "low": .low
        case "medium": .medium
        case "high": .high
            
        default: .low
        }
    }
    
}

struct ScanConfidence: Codable {
    let level: ConfidenceLevel
    let explanation: String?
}
