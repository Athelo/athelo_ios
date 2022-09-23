//
//  File.swift
//  
//
//  Created by Krzysztof Jabłoński on 23/06/2022.
//

import Combine
import Foundation

public extension AtheloAPI {
    enum FAQ {
        private typealias Builder = FAQRequestBuilder
        
        public static func list<T: Decodable>() -> AnyPublisher<ListResponseData<T>, APIError> {
            APIService().request(with: Builder.list).eraseToAnyPublisher()
        }
    }
}
