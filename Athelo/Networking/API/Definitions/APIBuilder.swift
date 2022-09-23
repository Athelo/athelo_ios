//
//  File.swift
//  
//
//  Created by Krzysztof Jabłoński on 30/05/2022.
//

import Foundation

protocol APIBuilderProtocol {
    var contentType: APIContentType { get }
    var headers: [String: String]? { get }
    var method: APIMethod { get }
    var parameters: [String: Any]? { get }
    var path: String { get }
}

extension APIBuilderProtocol {
    var contentType: APIContentType {
        .json
    }
}

extension APIBuilderProtocol {
    func buildURLRequest() -> URLRequest {
        guard let servicePath = try? APIEnvironment.storedServicePath() else {
            preconditionFailure("Missing service path.")
        }
        
        guard let url = URL(string: servicePath + path) else {
            preconditionFailure("Invalid API service configuration for \(path).")
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.httpMethod

        guard let applicationIdentifier = try? APIEnvironment.storedApplicationIdentifier() else {
            preconditionFailure("Missing application identifier.")
        }
        
        request.addValue(applicationIdentifier, forHTTPHeaderField: "X-Application-Identifier")
        request.addValue("IOS", forHTTPHeaderField: "X-Device-Type")
        request.addValue(TimeZone.current.identifier, forHTTPHeaderField: "X-Timezone")
        
        if let token = APIEnvironment.storedUserToken()?.accessToken, !token.isEmpty {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let version = try? APIEnvironment.storedAppVersion() {
            request.addValue(version, forHTTPHeaderField: "X-App-Version")
        }

        headers?.forEach({
            request.addValue($0.value, forHTTPHeaderField: $0.key)
        })

        switch contentType {
        case .json:
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")

            if let parameters = parameters, !parameters.isEmpty,
               let data = try? JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) {
                request.httpBody = data
            }
        case .multipartJPEG(let imageData):
            let boundary = "Boundary-\(ProcessInfo.processInfo.globallyUniqueString)"
            request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

            let imageName = "image-\(UUID().uuidString.lowercased())-\(Date().hashValue)"
            
            var httpBodyStart = "--\(boundary)\r\n"
            httpBodyStart += "Content-Disposition: form-data; name=\"image\"; filename=\"\(imageName).jpeg\"\r\n"
            httpBodyStart += "Content-Type: image/jpeg\r\n\r\n"

            let httpBodyEnd = "\r\n--\(boundary)--\r\n"

            if let httpBodyStartData = httpBodyStart.data(using: .utf8),
               let httpBodyEndData = httpBodyEnd.data(using: .utf8) {
                var data = Data()

                data.append(httpBodyStartData)
                data.append(imageData)
                data.append(httpBodyEndData)

                request.httpBody = data
            }
        }

        return request
    }
}
