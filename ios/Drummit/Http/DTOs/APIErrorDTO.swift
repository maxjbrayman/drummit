//
//  APIErrorDTO.swift
//  Drummit
//

import Foundation

/// The body the server sends with an error response: {"error": "..."}.
/// Matches APIError in the Go server's client/errors.go.
struct APIErrorDTO: Decodable {
    let error: String
}
