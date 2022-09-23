//
//  File.swift
//  
//
//  Created by Krzysztof Jabłoński on 28/07/2022.
//

import Combine
import Foundation

public extension AtheloAPI {
    enum DeviceConfig {
        private typealias Builder = DeviceConfigRequestBuilder
        
        public static func deviceConfig<T: Decodable>() -> AnyPublisher<T, APIError> {
            APIService().request(with: Builder.deviceConfig).eraseToAnyPublisher()
        }
    }
}
