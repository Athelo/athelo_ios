import Combine
import Foundation

public extension AtheloAPI {
    enum Events {
        private typealias Builder = EventsRequestBuilder
        
        public static func categories<T: Decodable>() -> AnyPublisher<ListResponseData<T>, APIError> {
            APIService().request(with: Builder.categories).eraseToAnyPublisher()
        }

        public static func details<T: Decodable>(request: EventDetailsRequest) -> AnyPublisher<T, APIError> {
            APIService().request(with: Builder.details(request: request)).eraseToAnyPublisher()
        }

        public static func list<T: Decodable>(request: EventsListRequest) -> AnyPublisher<ListResponseData<T>, APIError> {
            APIService().request(with: Builder.list(request: request)).eraseToAnyPublisher()
        }
    }
}
