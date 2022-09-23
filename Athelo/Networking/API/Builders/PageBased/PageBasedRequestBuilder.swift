import Foundation

enum PageBasedRequestBuilder: APIBuilderProtocol {
    case nextPage(URL)

    var headers: [String : String]? {
        switch self {
        case .nextPage:
            return nil
        }
    }

    var method: APIMethod {
        switch self {
        case .nextPage:
            return .get
        }
    }

    var parameters: [String : Any]? {
        switch self {
        case .nextPage:
            return nil
        }
    }

    var path: String {
        switch self {
        case .nextPage(let url):
            guard let path = try? APIEnvironment.storedServicePath() else {
                fatalError("Unknown service path.")
            }
            
            return url.absoluteString.replacingOccurrences(of: path, with: "")
        }
    }
}
