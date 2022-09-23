//
//  File.swift
//  
//
//  Created by Krzysztof Jabłoński on 31/05/2022.
//

import Foundation

extension Array where Element == URLQueryItem {
    func intoQuery() -> String {
        let query = "?\(map({ $0.description }).joined(separator: "&"))"
        return query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
    }
}
