import Foundation

enum ContactsRequestBuilder: APIBuilderProtocol {
    case friends
    case invitation(request: ContactsInvitationRequest)
    case invitationList(request: ContactsInvitationListRequest)
    case removeFriend(request: ContactsRemoveFriendRequest)
    case report(request: ContactsReportProfileRequest)
    case search(request: ContactsSearchRequest)
    case sendInvite(request: ContactsSendInviteRequest)
    case updateInvite(request: ContactsUpdateInviteRequest)

    var headers: [String : String]? {
        switch self {
        case .friends, .invitation, .invitationList, .removeFriend, .report, .search, .sendInvite, .updateInvite:
            return nil
        }
    }

    var method: APIMethod {
        switch self {
        case .friends, .invitation, .invitationList, .search:
            return .get
        case .removeFriend:
            return .delete
        case .report, .sendInvite, .updateInvite:
            return .post
        }
    }

    var parameters: [String : Any]? {
        switch self {
        case .friends:
            return nil
        case .invitation(let request as APIRequest),
             .invitationList(let request as APIRequest),
             .removeFriend(let request as APIRequest),
             .report(let request as APIRequest),
             .search(let request as APIRequest),
             .sendInvite(let request as APIRequest),
             .updateInvite(let request as APIRequest):
            return request.parameters
        }
    }

    var path: String {
        switch self {
        case .friends:
            return "/users/friends/"
        case .invitation(let request):
            return "/users/friend-requests/\(request.invitationID)/"
        case .invitationList(let request):
            var path = "/users/friend-requests/\(request.type.path)/"

            if let status = request.status {
                path += "?status=\(status)"
            }

            return path
        case .removeFriend(let request):
            return "/users/friends/\(request.relationID)/"
        case .report(let request):
            return "/users/user-profiles/\(request.userID)/report-profile/"
        case .search(let request):
            var path = "/users/user-profiles/?"
            
            if let query = request.query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), !query.isEmpty {
                path += "&search__contains=\(query)"
            }

            if let isFriend = request.isFriend {
                path += "&is_friend=\(isFriend ? "true" : "false")"
            }

            if let profileTagIDs = request.profileTagIDs, !profileTagIDs.isEmpty {
                path += "&tags__contains=\(profileTagIDs.map({ "\($0)" }).joined(separator: ","))"
            }

            return path
        case .sendInvite:
            return "/users/friend-requests/"
        case .updateInvite(let request):
            return "/users/friend-requests/received/\(request.inviteID)/answer/"
        }
    }
}

// MARK: - Helper extensions
private extension ContactsInvitationListRequest.RequestType {
    var path: String {
        switch self {
        case .received:
            return "received"
        case .sent:
            return "sent"
        }
    }
}
