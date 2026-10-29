//
//  Client.swift
//  Drummit
//
//  Created by Max Brayman on 10/15/26.
//

import Foundation

protocol Client {
    func request<Response: Decodable>(path: String, method: HttpMethod, payload: Data?, params: [String:String]?, headers: [String : String]?) async throws -> Response
}

extension Client {
    func get<Response: Decodable>(path: String, params: [String:String]?, headers: [String:String]?) async throws -> Response {
        try await request(path: path, method: .get, payload: nil, params: params, headers: headers)
    }
    
    func post<Response: Decodable>(path: String, payload: Data?, params: [String:String]?, headers: [String:String]?) async throws -> Response {
        try await request(
            path: path,
            method: .post,
            payload: payload,
            params: params,
            headers: headers
        )
    }
}
