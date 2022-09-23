import Combine
import Foundation

public extension AtheloAPI {
    enum Tags {
        private typealias Builder = TagRequestBuilder

        public static func categories<T: Decodable>() -> AnyPublisher<ListResponseData<T>, APIError> {
            APIService().request(with: Builder.categories).eraseToAnyPublisher()
        }

        public static func list<T: Decodable>(request: TagListRequest) -> AnyPublisher<ListResponseData<T>, APIError> {
            APIService().request(with: Builder.list(request: request)).eraseToAnyPublisher()
        }

        public static func tree<T: Decodable>(request: TagTreeRequest) -> AnyPublisher<[T], APIError> {
            APIService().request(with: Builder.tree(request: request)).eraseToAnyPublisher()
        }
    }
}
