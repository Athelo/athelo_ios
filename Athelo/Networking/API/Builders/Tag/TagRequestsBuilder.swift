import Foundation

enum TagRequestBuilder: APIBuilderProtocol {
    case categories
    case list(request: TagListRequest)
    case tree(request: TagTreeRequest)

    var headers: [String : String]? {
        switch self {
        case .categories, .list, .tree:
            return nil
        }
    }

    var method: APIMethod {
        switch self {
        case .categories, .list, .tree:
            return .get
        }
    }

    var parameters: [String : Any]? {
        switch self {
        case .categories:
            return nil
        case .list(let request as APIRequest),
             .tree(let request as APIRequest):
            return request.parameters
        }
    }

    var path: String {
        switch self {
        case .categories:
            return "/tags/tag-categories/"
        case .list(let request):
            var path = "/tags/person-tags/"

            if let categoryID = request.categoryID {
                path += "?category=\(categoryID)"
            }

            return path
        case .tree(let request):
            var path = "/tags/person-tags/tree-list/"

            if let categoryID = request.categoryID {
                path += "?category=\(categoryID)"
            }

            return path
        }
    }
}
