import Combine
import Foundation

public extension AtheloAPI {
    enum Authentication {
        private typealias Builder = AuthenticationRequestBuilder

        public static func login(request: AuthenticationLoginRequest) -> AnyPublisher<IdentityTokenDataWrapper, APIError> {
            APIService().request(with: Builder.login(request: request)).eraseToAnyPublisher()
        }

        public static func loginUsingSocialProfile(request: AuthenticationLoginWithSocialProfileRequest) -> AnyPublisher<IdentityTokenDataWrapper, APIError> {
            APIService().request(with: Builder.loginWithSocialProfile(request: request)).eraseToAnyPublisher()
        }

        public static func register(request: AuthenticationRegisterRequest) -> AnyPublisher<IdentityTokenDataWrapper, APIError> {
            APIService().request(with: Builder.register(request: request)).eraseToAnyPublisher()
        }
    }
}
