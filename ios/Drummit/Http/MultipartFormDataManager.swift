//
//  MultipartFormDataManager.swift
//  Drummit
//
//  Created by Max Brayman on 10/15/26.
//

import Foundation

enum FormDataValue {
    case stringType(string: String)
    case fileType(
        contentType: String,
        fileName: String,
        data: Data
    )
}

struct FormDataEntry {
    let key: String
    let value: FormDataValue
}


struct MultipartFormDataManager {
    private let newLine = "\r\n"
    
    func getBodyAndHeader(formData: [FormDataEntry]) -> (body: Data, contentType: String) {
        let boundary = createBoundary()
        let body = createBody(formData: formData, boundary: boundary)
        
        return (body: body, contentType: "multipart/form-data; boundary=\(boundary)")
    }
    
    private func createBoundary() -> String {
        "Boundary-\(UUID().uuidString)"
    }
    
    private func createBody(formData: [FormDataEntry], boundary: String) -> Data {
        var body = Data()
        let boundarySeparator = "--\(boundary)\r\n".data(using: .utf8)!
        let closingBoundary = "--\(boundary)--\r\n".data(using: .utf8)!
        
        for entry in formData {
            body.append(boundarySeparator)
            
            switch entry.value {
            case .stringType(string: let string):
                body.append("Content-Disposition: form-data; name=\"\(entry.key)\"\(newLine)\(newLine)".data(using: .utf8)!)
                body.append(string.data(using: .utf8)!)
                
            case .fileType(contentType: let contentType, fileName: let fileName, data: let data):
                body.append("Content-Disposition: form-data; name=\"\(entry.key)\"; filename=\"\(fileName)\"\(newLine)".data(using: .utf8)!)
                body.append("Content-Type: \(contentType)\(newLine)\(newLine)".data(using: .utf8)!)
                body.append(data)
            }
            body.append("\(newLine)".data(using: .utf8)!)
        }
        body.append(closingBoundary)
        
        return body
    }
}
