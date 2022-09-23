import Combine
import Foundation

public extension AtheloAPI {
    enum Posts {
        private typealias Builder = PostsRequestBuilder
        
        public static func addFavorite(request: PostAddFavoriteRequest) -> AnyPublisher<Never, APIError> {
            APIService().request(with: Builder.addFavorite(request: request)).eraseToAnyPublisher()
        }
        
        public static func addPhotoToComment(request: PostAddPhotoToCommentRequest) -> AnyPublisher<Never, APIError> {
            APIService().request(with: Builder.addPhotoToComment(request: request)).eraseToAnyPublisher()
        }

        public static func categories<T: Decodable>() -> AnyPublisher<ListResponseData<T>, APIError> {
            APIService().request(with: Builder.categories).eraseToAnyPublisher()
        }

        public static func commentDetails<T: Decodable>(request: PostCommentDetailsRequest) -> AnyPublisher<T, APIError> {
            APIService().request(with: Builder.commentDetails(request: request)).eraseToAnyPublisher()
        }
        
        public static func comments<T: Decodable>(request: PostCommentsRequest) -> AnyPublisher<ListResponseData<T>, APIError> {
            APIService().request(with: Builder.comments(request: request)).eraseToAnyPublisher()
        }

        public static func createComment<T: Decodable>(request: PostCreateCommentRequest) -> AnyPublisher<T, APIError> {
            APIService().request(with: Builder.createComment(request: request)).eraseToAnyPublisher()
        }

        public static func createPost<T: Decodable>(request: PostCreatePostRequest) -> AnyPublisher<T, APIError> {
            APIService().request(with: Builder.createPost(request: request)).eraseToAnyPublisher()
        }

        public static func details<T: Decodable>(request: PostDetailsRequest) -> AnyPublisher<T, APIError> {
            APIService().request(with: Builder.details(request: request)).eraseToAnyPublisher()
        }

        public static func list<T: Decodable>(request: PostListRequest) -> AnyPublisher<ListResponseData<T>, APIError> {
            APIService().request(with: Builder.list(request: request)).eraseToAnyPublisher()
        }
        
        public static func removeFavorite(request: PostRemoveFavoriteRequest) -> AnyPublisher<Never, APIError> {
            APIService().request(with: Builder.removeFavorite(request: request)).eraseToAnyPublisher()
        }
    }
}
