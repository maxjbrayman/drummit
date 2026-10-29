//
//  HttpClient.swift
//  Drummit
//
//  Created by Max Brayman on 10/15/26.
//

import Foundation

enum HttpError: Error {
    case invalidURL
    case invalidPayload
    case invalidResponse
    case notFound
    case forbidden
    case notAuthenticated
    case serverError(code: Int)
    
    var message: String {
        switch self {
        case .invalidURL:
            "The provided URL is invalid."
        case .invalidPayload:
            "The provided payload is invalid."
        case .invalidResponse:
            "The server was unable to provide a valid response."
        case .notFound:
            "The resource or path could not be found."
        case .forbidden:
            "The requested action is not allowed."
        case .notAuthenticated:
            "The requested action requires authentication."
        case .serverError:
            "An unknown server error occurred."
        }
    }
}

struct HttpClient: Client {
    let baseURL: String
    
    func request<Response: Decodable>(
        path: String,
        method: HttpMethod,
        payload: Data?,
        params: [String : String]?,
        headers: [String : String]?
    ) async throws -> Response {
        var urlRequest = try createRequest(
            path: path,
            method: method,
            params: params,
            headers: headers
        )
        
        if let payload {
            urlRequest.httpBody = payload
        }
        
        return try await makeRequest(urlRequest)
        
    }
    
    private func createRequest(path: String,
                               method: HttpMethod,
                               params: [String : String]?,
                               headers: [String : String]?) throws -> URLRequest {
        guard let baseURL = URL(string: self.baseURL) else {
            throw HttpError.invalidURL
        }
        
        let url = baseURL.appending(path: path)
        guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            throw HttpError.invalidURL
        }
        
        if let params {
            let queryItems = params.map {
                URLQueryItem(name: $0.key, value: $0.value)
            }
            urlComponents.queryItems = queryItems
        }
        
        guard let finalUrl = urlComponents.url else {
            throw HttpError.invalidURL
        }
        
        var urlRequest = URLRequest(url: finalUrl)
        urlRequest.httpMethod = method.rawValue
        urlRequest.timeoutInterval = 120
        
        if let headers {
            headers.forEach {
                urlRequest.setValue($0.value, forHTTPHeaderField: $0.key)
            }
        }
        
        return urlRequest
    }
    
    private func makeRequest<Response: Decodable>(_ urlRequest: URLRequest) async throws -> Response {
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw HttpError.invalidResponse
        }
                
        switch httpResponse.statusCode {
        case 200...299: break
        case 404: throw HttpError.notFound
        case 403: throw HttpError.forbidden
        case 401: throw HttpError.notAuthenticated
        default: throw HttpError.serverError(code: httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        
        return try decoder.decode(Response.self, from: data)
    }
}
