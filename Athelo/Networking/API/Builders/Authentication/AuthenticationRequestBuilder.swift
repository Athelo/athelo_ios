import Foundation

enum AuthenticationRequestBuilder: APIBuilderProtocol {
    case login(request: AuthenticationLoginRequest)
    case loginWithSocialProfile(request: AuthenticationLoginWithSocialProfileRequest)
    case register(request: AuthenticationRegisterRequest)

    var headers: [String : String]? {
        switch self {
        case .login, .loginWithSocialProfile, .register:
            return nil
        }
    }

    var method: APIMethod {
        switch self {
        case .login, .loginWithSocialProfile, .register:
            return .post
        }
    }

    var parameters: [String : Any]? {
        switch self {
        case .login(let request as APIRequest),
             .loginWithSocialProfile(let request as APIRequest),
             .register(let request as APIRequest):
            return request.parameters
        }
    }

    var path: String {
        switch self {
        case .login:
            return "/common/i2a-oauth2/login/"
        case .loginWithSocialProfile:
            return "/common/i2a-oauth2/login-social/"
        case .register:
            return "/common/i2a-oauth2/register/"
        }
    }
}
