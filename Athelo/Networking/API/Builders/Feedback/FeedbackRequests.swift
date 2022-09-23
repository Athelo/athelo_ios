import Combine
import Foundation

public extension AtheloAPI {
    enum Feedback {
        private typealias Builder = FeedbackRequestBuilder
        
        public static func sendFeedback<T: Decodable>(request: FeedbackRequest) -> AnyPublisher<T, APIError> {
            APIService().request(with: Builder.feedback(request: request)).eraseToAnyPublisher()
        }
        
        public static func topics<T: Decodable>() -> AnyPublisher<ListResponseData<T>, APIError> {
            APIService().request(with: Builder.topics).eraseToAnyPublisher()
        }
    }
}
