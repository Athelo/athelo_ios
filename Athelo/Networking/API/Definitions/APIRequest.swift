//
//  File.swift
//  
//
//  Created by Krzysztof Jabłoński on 30/05/2022.
//

import Foundation

public protocol APIRequest {
    var parameters: [String: Any]? { get }
}
