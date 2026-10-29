//
//  StickType.swift
//  Drummit
//
//  Created by Max Brayman on 10/12/26.
//

import Foundation

enum StickType: Codable {
    case wood
    case nylon
    
    var displayName: String {
        switch self {
        case .wood:
            "Wood Tip"
        case .nylon:
            "Nylon Tip"
        }
    }
    
    static func create(from string: String?) -> StickType? {
        guard let lowercased = string?.lowercaseAndStripSeparators() else {
            return nil
        }
        
        if lowercased.contains("wood") { return .wood }
        if lowercased.contains("nylon") { return .nylon }
        
        return nil
    }
}
