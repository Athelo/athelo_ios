//
//  File.swift
//  
//
//  Created by Krzysztof Jabłoński on 01/08/2022.
//

import Foundation

public struct FitbitDeleteProfileRequest: APIRequest {
    let id: Int
    
    public init(id: Int) {
        self.id = id
    }
    
    public var parameters: [String : Any]? {
        nil
    }
}
