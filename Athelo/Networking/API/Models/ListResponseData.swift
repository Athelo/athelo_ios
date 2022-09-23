//
//  File.swift
//  
//
//  Created by Krzysztof Jabłoński on 30/05/2022.
//

import Foundation

public struct ListResponseData<T: Decodable>: Decodable {
    public let count: Int
    public let next: URL?
    public let previous: URL?
    public let results: [T]
}
