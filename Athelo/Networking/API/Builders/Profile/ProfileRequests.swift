import Combine
import Foundation

public extension AtheloAPI {
    enum Profile {
        public enum RequestError: Error {
            case profileNotAvailable

            var localizedDescription: String {
                switch self {
                case .profileNotAvailable:
                    return "Profile details could not be downloaded. Please check your internet connection and try again later."
                }
            }
        }
        
        private typealias Builder = ProfileRequestBuilder
        
        public static func addTags(request: ProfileAddTagsRequest) -> AnyPublisher<Never, APIError> {
            APIService().request(with: Builder.addTags(request: request)).eraseToAnyPublisher()
        }
        
        public static func authorizationMethods<T: Decodable>() -> AnyPublisher<T, APIError> {
            APIService().request(with: Builder.authorizationMethods).eraseToAnyPublisher()
        }

        public static func currentUserDetails<T: Decodable>() -> AnyPublisher<T, APIError> {
            APIService().request(with: Builder.currentUserDetails)
                .tryMap({ (value: ListResponseData<T>) -> T in
                    guard let profile = value.results.first else {
                        throw RequestError.profileNotAvailable
                    }

                    return profile
                })
                .mapError({ APIError.convertToAPIError($0) })
                .eraseToAnyPublisher()
        }
        
        public static func deleteAccount() -> AnyPublisher<Never, APIError> {
            APIService().request(with: Builder.deleteAccount).eraseToAnyPublisher()
        }

        public static func create<T: Decodable>(request: ProfileCreateRequest) -> AnyPublisher<T, APIError> {
            APIService().request(with: Builder.create(request: request)).eraseToAnyPublisher()
        }

        public static func removeTags(request: ProfileRemoveTagsRequest) -> AnyPublisher<Never, APIError> {
            APIService().request(with: Builder.removeTags(request: request)).eraseToAnyPublisher()
        }

        public static func update<T: Decodable>(request: ProfileUpdateRequest) -> AnyPublisher<T, APIError> {
            APIService().request(with: Builder.update(request: request)).eraseToAnyPublisher()
        }

        public static func userDetails<T: Decodable>(request: ProfileDetailsRequest) -> AnyPublisher<T, APIError> {
            APIService().request(with: Builder.details(request: request)).eraseToAnyPublisher()
        }
    }
}
