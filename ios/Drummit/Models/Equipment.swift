//
//  Equipment.swift
//  Drummit
//
//  Created by Max Brayman on 10/1/26.
//

import Foundation

struct RetailItem: Identifiable {
    let retailer: Retailer
    let url: URL
    
    var id: String { retailer.displayName }
}

enum EquipmentKind: Codable {
    case cymbal(type: CymbalType? = nil, size: Double?)
    case stick(type: StickType? = nil)
    case drum(type: DrumType? = nil, depth: Double?, diameter: Double?)
    case pedal
    case hardware(type: String?)
    case other(details: String?)
}

/// Note: This enum is used to map the EquipmentKind enum to one that is CaseIterable without having to worry about associated values
/// EquipmentKind is extended with a category var which is a 1:1 map from the EquipmentKind value
nonisolated enum EquipmentCategory: String, CaseIterable, Codable, Identifiable {
    case cymbal, drum, stick, pedal, hardware, other

    var id: Self { self }

    var displayName: String {
        switch self {
        case .cymbal: "Cymbals"
        case .drum: "Drums"
        case .stick: "Sticks"
        case .pedal: "Pedals"
        case .hardware: "Hardware"
        case .other: "Other"
        }
    }
}

extension EquipmentKind {
    var category: EquipmentCategory {
        switch self {
        case .cymbal: .cymbal
        case .drum: .drum
        case .stick: .stick
        case .pedal: .pedal
        case .hardware: .hardware
        case .other: .other
        }
    }
}

struct Equipment: Codable {
    let brand: String?
    let model: String?
    let kind: EquipmentKind
        
    var displayTitle: String {
        var titleTerms: [String] = []
        if let brand { titleTerms.append(brand) }
        if let model { titleTerms.append(model) }
        
        switch kind {
        case let .cymbal(type, _):
            if let type {
                switch type {
                case .ride:
                    titleTerms.append("Ride Cymbal")
                case .crash:
                    titleTerms.append("Crash Cymbal")
                case .hihat:
                    titleTerms.append("Hi Hat")
                case .splash:
                    titleTerms.append("Splash Cymbal")
                case .china:
                    titleTerms.append("China Cymbal")
                case .fx:
                    titleTerms.append("FX Cymbal")
                case .other:
                    titleTerms.append("Cymbal")
                }
            }
        case .stick:
            titleTerms.append("Drumsticks")
        case .drum(let type, _, _):
            switch type {
            case .snare:
                titleTerms.append("Snare Drum")
            case .bass:
                titleTerms.append("Bass Drum")
            case .tom:
                titleTerms.append("Tom Drum")
            case .other:
                titleTerms.append("Drum")
            case nil: break
            }
        case .pedal:
            titleTerms.append("Pedal")
        case .hardware(let type):
            if let type {
                titleTerms.append(type)
            }
        case .other(let details):
            if let details {
                titleTerms.append(details)
            }
        }
        
        return titleTerms.joined(separator: " ")
    }
    
    var displayDescription: String? {
        switch kind {
        case let .cymbal(_, size):
            if let size {
                return "\(size.formatted()) in"
            }
        case let .drum(_, _, diameter):
            if let diameter {
                return "\(diameter.formatted()) in"
            }
        default: return nil
        }
        
        return nil
    }
    
    var searchTerms: [String] {
        var terms: [String] = []
        if let brand = brand { terms.append(brand) }
        if let model = model { terms.append(model) }
    
        switch kind {
        case let .cymbal(type, size):
            if let type { terms.append(type.searchTerm) }
            if let size {
                terms.append("\(size.formatted()) inches")
            }
        case .stick:
            terms.append("drumstick")
        case let .drum(type, depth, diameter):
            if let type { terms.append(type.searchTerm) }
            if let depth {
                terms.append("\(depth.formatted()) inches deep")
            }
            if let diameter {
                terms.append("\(diameter.formatted()) inches")
            }
        case .pedal:
            terms.append("kick pedal")
        case let .hardware(type):
            if let type { terms.append(type) }
        case let .other(details):
            if let details { terms.append(details) }
        }
        
        return terms
    }
    
    var urls: [ RetailItem ] {
        let queryString = searchTerms.joined(separator: " ")
        return [
            RetailItem(retailer: .sweetwater, url: RetailUrls
                .sweetwaterURL(query: queryString)
            ),
            RetailItem(retailer: .guitarCenter, url: RetailUrls
                .guitarCenterURL(query: queryString)
            ),
            RetailItem(retailer: .reverb, url: RetailUrls
                .reverbURL(query: queryString)
            )
        ]
    }
}
