//
//  DrumType.swift
//  Drummit
//
//  Created by Max Brayman on 10/1/26.
//

import Foundation

enum DrumType: Codable {
    case snare
    case bass
    case tom
    case other
    
    var displayName: String {
        switch self {
        case .snare:
            "Snare"
        case .bass:
            "Bass"
        case .tom:
            "Tom"
        case .other:
            "Other"
        }
    }
    
    var searchTerm: String {
        switch self {
        case .snare:
            "snare"
        case .bass:
            "bass"
        case .tom:
            "tom"
        case .other:
            "drum"
        }
    }
    
    static func create(from string: String?) -> DrumType {
        guard let lowercased = string?.lowercaseAndStripSeparators() else {
            return .other
        }
        
        if lowercased.contains("snare") { return .snare }
        if lowercased.contains("bass") || lowercased.contains("kick") { return .bass }
        if lowercased.contains("tom") { return .tom }
        
        return .other
    }
}
