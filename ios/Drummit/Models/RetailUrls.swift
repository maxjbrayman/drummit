//
//  RetailUrls.swift
//  Drummit
//
//  Created by Max Brayman on 10/1/26.
//

import Foundation

enum Retailer {
    case sweetwater
    case reverb
    case guitarCenter
    
    var displayName: String {
        switch self {
        case .sweetwater:
            "Sweetwater"
        case .reverb:
            "Reverb"
        case .guitarCenter:
            "Guitar Center"
        }
    }
}

enum RetailUrls {
    static let sweetwaterBaseURL = "https://www.sweetwater.com/store/search"
    static let guitarCenterBaseURL = "https://www.guitarcenter.com/search"
    static let reverbBaseURL = "https://reverb.com/marketplace"
    
    static func sweetwaterURL(query: String) -> URL {
        let url = URL(string: RetailUrls.sweetwaterBaseURL)!
        
        let searchQueryItem = URLQueryItem(name: "s", value: query)
        return url.appending(queryItems: [searchQueryItem])
    }
    
    static func guitarCenterURL(query: String) -> URL {
        let url = URL(string: RetailUrls.guitarCenterBaseURL)!
        
        let searchQueryItem = URLQueryItem(name: "Ntt", value: query)
        return url.appending(queryItems: [searchQueryItem])
    }
    
    static func reverbURL(query: String) -> URL {
        let url = URL(string: RetailUrls.reverbBaseURL)!
        
        let searchQueryItem = URLQueryItem(name: "query", value: query)
        return url.appending(queryItems: [searchQueryItem])
    }
}
