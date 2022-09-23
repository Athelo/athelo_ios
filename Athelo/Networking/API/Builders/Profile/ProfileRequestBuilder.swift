import Foundation

enum ProfileRequestBuilder: APIBuilderProtocol {
    case addTags(request: ProfileAddTagsRequest)
    case authorizationMethods
    case create(request: ProfileCreateRequest)
    case currentUserDetails
    case deleteAccount
    case details(request: ProfileDetailsRequest)
    case removeTags(request: ProfileRemoveTagsRequest)
    case update(request: ProfileUpdateRequest)

    var headers: [String : String]? {
        switch self {
        case .addTags, .authorizationMethods, .create, .currentUserDetails, .deleteAccount, .details, .removeTags, .update:
            return nil
        }
    }

    var method: APIMethod {
        switch self {
        case .addTags, .create, .removeTags:
            return .post
        case .authorizationMethods, .currentUserDetails, .deleteAccount, .details:
            return .get
        case .update:
            return .patch
        }
    }

    var parameters: [String : Any]? {
        switch self {
        case .addTags(let request as APIRequest),
             .create(let request as APIRequest),
             .details(let request as APIRequest),
             .removeTags(let request as APIRequest),
             .update(let request as APIRequest):
            return request.parameters
        case .authorizationMethods, .currentUserDetails, .deleteAccount:
            return nil
        }
    }

    var path: String {
        switch self {
        case .addTags:
            return "/users/me/add-person-tags/"
        case .authorizationMethods:
            return "/users/me/authorization-identities/"
        case .create:
            return "/users/me/"
        case .currentUserDetails:
            return "/users/me/"
        case .deleteAccount:
            return "/users/me/delete/"
        case .details(let request):
            return "/users/user-profiles/\(request.userID)/"
        case .removeTags:
            return "/users/me/remove-person-tags/"
        case .update(let request):
            return "/users/me/\(request.userID)/"
        }
    }
}
