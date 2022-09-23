import Combine
import Foundation

public extension AtheloAPI {
    enum Locations {
        private typealias Builder = LocationRequestBuilder
        
        public static func categoryList<T: Decodable>() -> AnyPublisher<ListResponseData<T>, APIError> {
            APIService().request(with: Builder.categoriesList).eraseToAnyPublisher()
        }
        
        public static func details<T: Decodable>(request: LocationDetailsRequest) -> AnyPublisher<T, APIError> {
            APIService().request(with: Builder.details(request: request)).eraseToAnyPublisher()
        }
        
        public static func list<T: Decodable>(request: LocationListRequest) -> AnyPublisher<ListResponseData<T>, APIError> {
            APIService().request(with: Builder.list(request: request)).eraseToAnyPublisher()
        }
    }
}
