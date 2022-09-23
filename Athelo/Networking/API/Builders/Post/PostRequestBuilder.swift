import Foundation

enum PostsRequestBuilder: APIBuilderProtocol {
    case addFavorite(request: PostAddFavoriteRequest)
    case addPhotoToComment(request: PostAddPhotoToCommentRequest)
    case categories
    case commentDetails(request: PostCommentDetailsRequest)
    case comments(request: PostCommentsRequest)
    case createComment(request: PostCreateCommentRequest)
    case createPost(request: PostCreatePostRequest)
    case details(request: PostDetailsRequest)
    case list(request: PostListRequest)
    case removeFavorite(request: PostRemoveFavoriteRequest)

    var headers: [String : String]? {
        switch self {
        case .addFavorite, .addPhotoToComment, .categories, .commentDetails, .comments, .createComment, .createPost, .details, .list, .removeFavorite:
            return nil
        }
    }

    var method: APIMethod {
        switch self {
        case .categories, .commentDetails, .comments, .details, .list:
            return .get
        case .addFavorite, .addPhotoToComment, .createComment, .createPost, .removeFavorite:
            return .post
        }
    }

    var parameters: [String : Any]? {
        switch self {
        case .categories:
            return nil
        case .addFavorite(let request as APIRequest),
                .addPhotoToComment(let request as APIRequest),
                .commentDetails(let request as APIRequest),
                .comments(let request as APIRequest),
                .createComment(let request as APIRequest),
                .createPost(let request as APIRequest),
                .details(let request as APIRequest),
                .list(let request as APIRequest),
                .removeFavorite(let request as APIRequest):
            return request.parameters
        }
    }

    var path: String {
        switch self {
        case .addFavorite(let request):
            return "/posts/posts/\(request.postID)/add_to_favourites/"
        case .addPhotoToComment(let request):
            return "/posts/post-comments/\(request.commentID)/add-photo/"
        case .categories:
            return "/posts/post-categories/"
        case .commentDetails(let request):
            return "/posts/post-comments/\(request.commentID)/"
        case .comments(let request):
            return "/posts/post-comments/?post=\(request.id)"
        case .createComment:
            return "/posts/post-comments/"
        case .createPost:
            return "/posts/owned-posts/"
        case .details(let request):
            return "/posts/posts/\(request.id)/"
        case .list(let request):
            var path = "/posts/posts/"

            var queryItems: [URLQueryItem] = []

            if let categoryIDs = request.categoryIDs, !categoryIDs.isEmpty {
                queryItems.append(.init(name: "categories__id__in", value: categoryIDs.map({ "\($0)" }).joined(separator: ",")))
            }
            if let eventID = request.eventID, eventID > 0 {
                queryItems.append(.init(name: "events__contains", value: "\(eventID)"))
            }
            if let favorite = request.favorite {
                queryItems.append(.init(name: "is_favourite", value: "\(favorite)"))
            }
            if let pageSize = request.pageSize, pageSize > 0 {
                queryItems.append(.init(name: "page_size", value: "\(pageSize)"))
            }
            if let query = request.query, !query.isEmpty {
                queryItems.append(.init(name: "title__icontains", value: query))
            }

            if !queryItems.isEmpty {
                path += queryItems.intoQuery()
            }

            return path
        case .removeFavorite(let request):
            return "/posts/posts/\(request.postID)/remove_from_favourites/"
        }
    }
}
