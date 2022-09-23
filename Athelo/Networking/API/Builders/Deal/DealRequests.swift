import Combine
import Foundation

public extension AtheloAPI {
    enum Deals {
        private typealias Builder = DealRequestBuilder
        
        public static func details<T: Decodable>(request: DealDetailsRequest) -> AnyPublisher<T, APIError> {
            APIService().request(with: Builder.details(request: request)).eraseToAnyPublisher()
        }
        
        public static func list<T: Decodable>(request: DealListRequest) -> AnyPublisher<ListResponseData<T>, APIError> {
            APIService().request(with: Builder.list(request: request)).eraseToAnyPublisher()
        }
    }
}
