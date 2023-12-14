//
//  SocialAPIServices+Extensions.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 30/03/2023.
//

import Combine
import Foundation
import SocialAPI

extension Publisher {
    func repeating<T: Decodable>() -> AnyPublisher<[T], Failure> where Output == ListResponseData<T>, Failure == SocialAPIError {
        return Publishers.SocialPublishers.ListRepeatingPublisher(initialRequest: Deferred { self as! AnyPublisher<ListResponseData<T>, SocialAPIError> })
            .eraseToAnyPublisher()
    }
}
