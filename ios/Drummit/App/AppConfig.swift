//
//  AppConfig.swift
//  Drummit
//
//  Created by Max Brayman on 10/28/26.
//

import Foundation

enum AppConfig {
    static let apiBaseURL: String = {
        guard
            let value = Bundle.main.object(forInfoDictionaryKey: "APIBaseURL") as? String,
            !value.isEmpty
        else {
            fatalError("APIBaseURL is missing. Copy Config/Secrets.example.xcconfig to Config/Secrets.xcconfig.")
        }
        return value
    }()
}
