import Foundation

enum PasswordRequestBuilder: APIBuilderProtocol {
    case change(request: PasswordChangeRequest)
    case reset(request: PasswordResetRequest)

    var headers: [String : String]? {
        switch self {
        case .change, .reset:
            return nil
        }
    }

    var method: APIMethod {
        switch self {
        case .change, .reset:
            return .post
        }
    }

    var parameters: [String : Any]? {
        switch self {
        case .change(let request as APIRequest),
             .reset(let request as APIRequest):
            return request.parameters
        }
    }

    var path: String {
        switch self {
        case .change:
            return "/common/i2a-oauth2/password-change/"
        case .reset(let request):
            return "/common/i2a-oauth2/password-reset-request/\(request.type.validPathComponent)/"
        }
    }
}

private extension PasswordResetRequest.RequestType {
    var validPathComponent: String {
        switch self {
        case .code:
            return "generate-code"
        case .link:
            return "generate-link"
        }
    }
}
