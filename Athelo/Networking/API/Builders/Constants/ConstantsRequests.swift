import Combine
import Foundation

public extension AtheloAPI {
    enum Constants {
        private typealias Builder = ConstantsRequestBuilder

        public static func constants<T: Decodable>() -> AnyPublisher<T, APIError> {
            APIService().request(with: Builder.constants).eraseToAnyPublisher()
        }
    }
}


