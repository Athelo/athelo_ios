import Combine
import Foundation

public extension AtheloAPI {
    enum PageBased {
        private typealias Builder = PageBasedRequestBuilder
        
        public static func nextPage<T: Decodable>(pageData: ListResponseData<T>) -> AnyPublisher<ListResponseData<T>, APIError> {
            guard let url = pageData.next else {
                return Fail<ListResponseData<T>, APIError>(error: APIError.invalidRequest).eraseToAnyPublisher()
            }

            return nextPage(nextPageURL: url)
        }

        public static func nextPage<T: Decodable>(nextPageURL: URL) -> AnyPublisher<ListResponseData<T>, APIError> {
            return APIService().request(with: Builder.nextPage(nextPageURL)).eraseToAnyPublisher()
        }
    }
}
