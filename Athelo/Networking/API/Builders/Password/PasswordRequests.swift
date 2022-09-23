import Combine
import Foundation

public extension AtheloAPI {
    enum Passwords {
        typealias Builder = PasswordRequestBuilder
        
        public static func change(request: PasswordChangeRequest) -> AnyPublisher<PingbackResponseData, APIError> {
            APIService().request(with: Builder.change(request: request))
        }
        
        public static func reset(request: PasswordResetRequest) -> AnyPublisher<PingbackResponseData, APIError> {
            APIService().request(with: Builder.reset(request: request)).eraseToAnyPublisher()
        }
    }
}
