//
//  Cymbal.swift
//  Drummit
//
//  Created by Max Brayman on 10/1/26.
//

import Foundation

enum CymbalType: Codable {
    case ride
    case crash
    case hihat
    case splash
    case china
    case fx
    case other
    
    var displayName: String {
        switch self {
        case .ride:
            "Ride"
        case .crash:
            "Crash"
        case .hihat:
            "Hi Hat"
        case .splash:
            "Splash"
        case .china:
            "China"
        case .fx:
            "FX"
        case .other:
            "Other"
        }
    }
    
    var searchTerm: String {
        switch self {
        case .ride:
            "ride"
        case .crash:
            "crash"
        case .hihat:
            "hihat"
        case .splash:
            "splash"
        case .china:
            "china"
        case .fx:
            "fx"
        case .other:
            "cymbal"
        }
    }
    
    static func create(from string: String?) -> CymbalType {
        guard let lowercased = string?.lowercaseAndStripSeparators() else {
            return .other
        }
        
        if lowercased.contains("ride") { return .ride }
        if lowercased.contains("crash") { return .crash }
        if lowercased.contains("hihat") { return .hihat }
        if lowercased.contains("splash") { return .splash }
        if lowercased.contains("china") { return .china }
        if lowercased.contains("fx") { return .fx }
        
        return .other
    }
    
}
