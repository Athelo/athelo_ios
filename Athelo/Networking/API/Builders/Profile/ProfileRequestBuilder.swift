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
    case createProfile(request: ProfileCreateRequest1)
    case updateTreatmentStatus(request: ProfileTreatmentStatus)
    case treatmentStatus

    var headers: [String : String]? {
        switch self {
        case .addTags, .authorizationMethods, .create, .currentUserDetails, .deleteAccount, .details, .removeTags, .update, .createProfile, .treatmentStatus, .updateTreatmentStatus:
            return nil
        }
    }

    var method: APIMethod {
        switch self {
        case .addTags, .create, .removeTags, .createProfile:
            return .post
        case .authorizationMethods, .currentUserDetails, .deleteAccount, .details, .treatmentStatus:
            return .get
        case .update, .updateTreatmentStatus:
            return .put
        }
    }

    var parameters: [String : Any]? {
        switch self {
        case .addTags(let request as APIRequest),
             .create(let request as APIRequest),
             .details(let request as APIRequest),
             .removeTags(let request as APIRequest),
             .update(let request as APIRequest),
             .createProfile(let request as APIRequest),
             .updateTreatmentStatus(let request as APIRequest):
            return request.parameters
        case .authorizationMethods, .currentUserDetails, .deleteAccount, .treatmentStatus:
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
        case .createProfile:
            return "/users/user-profiles/"
        case .removeTags:
            return "/users/me/remove-person-tags/"
        case .update:
            return "/users/me/"
        case .treatmentStatus, .updateTreatmentStatus:
            return "/users/me/patient/"
            
        }
    }
}
