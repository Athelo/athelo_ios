import Combine
import Foundation

public extension AtheloAPI {
    enum Images {
        private typealias Builder = ImagesRequestBuilder
        
        public static func delete(request: ImagesDeleteRequest) -> AnyPublisher<Never, APIError> {
            APIService().request(with: Builder.delete(request: request)).eraseToAnyPublisher()
        }
        
        public static func upload<T: Decodable>(request: ImagesUploadRequest) -> AnyPublisher<T, APIError> {
            APIService().request(with: Builder.upload(request: request)).eraseToAnyPublisher()
        }
    }
}
