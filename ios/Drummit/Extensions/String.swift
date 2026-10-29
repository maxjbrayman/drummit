//
//  String.swift
//  Drummit
//
//  Created by Max Brayman on 10/16/26.
//

import Foundation

extension String {
    func lowercaseAndStripSeparators() -> String {
        self.lowercased().replacingOccurrences(of: "[^a-z]", with: "", options: .regularExpression)
    }
    
    func pluralize(count: Int, suffix: String = "s") -> String {
        "\(self)\(count == 1 ? "" : "\(suffix)")"
    }
}
