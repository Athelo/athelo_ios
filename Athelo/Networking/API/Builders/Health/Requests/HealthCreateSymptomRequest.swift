//
//  File.swift
//  
//
//  Created by Krzysztof Jabłoński on 14/07/2022.
//

import Foundation

public struct HealthCreateSymptomRequest: APIRequest {
    let name: String
    let description: String?
    
    public init(name: String, description: String?) {
        self.name = name
        self.description = description
    }
    
    public var parameters: [String : Any]? {
        var params: [String: Any] = [
            "name": name
        ]
        
        if let description = description, !description.isEmpty {
            params["description"] = description
        }
        
        return params
    }
}
