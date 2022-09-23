import Foundation

enum ConstantsRequestBuilder: APIBuilderProtocol {
    case constants

    var headers: [String : String]? {
        switch self {
        case .constants:
            return nil
        }
    }

    var method: APIMethod {
        switch self {
        case .constants:
            return .get
        }
    }

    var parameters: [String : Any]? {
        switch self {
        case .constants:
            return nil
        }
    }

    var path: String {
        switch self {
        case .constants:
            return "/common/enums/"
        }
    }
}
