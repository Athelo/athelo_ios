//
//  File.swift
//  
//
//  Created by Krzysztof Jabłoński on 21/07/2022.
//

import Combine
import Foundation

public extension AtheloAPI {
    enum Applications {
        private typealias Builder = ApplicationsRequestBuilder
        
        public static func applications<T: Decodable>() -> AnyPublisher<ListResponseData<T>, APIError> {
            APIService().request(with: Builder.applications).eraseToAnyPublisher()
        }
    }
}
