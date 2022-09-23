//
//  File.swift
//  
//
//  Created by Krzysztof Jabłoński on 21/06/2022.
//

import Combine
import Foundation

public extension AtheloAPI {
    enum Fitbit {
        private typealias Builder = FitbitRequestBuilder
        
        public static func deleteProfile(request: FitbitDeleteProfileRequest) -> AnyPublisher<Never, APIError> {
            APIService().request(with: Builder.deleteProfile(request)).eraseToAnyPublisher()
        }
        
        public static func initializeAccess() -> AnyPublisher<URLResponseData, APIError> {
            APIService().request(with: Builder.initialize).eraseToAnyPublisher()
        }
        
        public static func profileList<T: Decodable>() -> AnyPublisher<ListResponseData<T>, APIError> {
            APIService().request(with: Builder.profileList).eraseToAnyPublisher()
        }
    }
}
