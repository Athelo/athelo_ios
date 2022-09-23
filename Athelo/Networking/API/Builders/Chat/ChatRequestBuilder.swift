import Foundation

enum ChatRequestBuilder: APIBuilderProtocol {
    case addUsers(request: ChatAddUsersRequest)
    case changeOwner(request: ChatChangeOwnerRequest)
    case closeSession(request: ChatCloseSessionRequest)
    case conversationDetails(request: ChatConversationDetailsRequest)
    case conversationList(request: ChatConversationListRequest)
    case createConversation(request: ChatCreateConversationRequest)
    case createGroupConversation(request: ChatCreateGroupConversationRequest)
    case groupConversationDetails(request: ChatGroupConversationDetailsRequest)
    case groupConversationList(request: ChatGroupConversationListRequest)
    case leaveGroupConversation(request: ChatLeaveGroupConversationRequest)
    case joinGroupConversation(request: ChatJoinGroupConversationRequest)
    case openSession(request: ChatOpenSessionRequest)
    case removeUsers(request: ChatRemoveUsersRequest)
    case reportMessage(request: ChatReportMessageRequest)

    var headers: [String : String]? {
        switch self {
        case .addUsers, .changeOwner, .closeSession, .conversationDetails, .conversationList, .createConversation, .createGroupConversation, .groupConversationDetails, .groupConversationList, .leaveGroupConversation, .joinGroupConversation, .openSession, .removeUsers, .reportMessage:
            return nil
        }
    }

    var method: APIMethod {
        switch self {
        case .addUsers, .changeOwner, .closeSession, .createConversation, .createGroupConversation, .openSession, .removeUsers, .reportMessage:
            return .post
        case .conversationDetails, .conversationList, .groupConversationDetails, .groupConversationList, .leaveGroupConversation, .joinGroupConversation:
            return .get
        }
    }

    var parameters: [String : Any]? {
        switch self {
        case .addUsers(let request as APIRequest),
             .changeOwner(let request as APIRequest),
             .closeSession(let request as APIRequest),
             .conversationDetails(let request as APIRequest),
             .conversationList(let request as APIRequest),
             .createConversation(let request as APIRequest),
             .createGroupConversation(let request as APIRequest),
             .groupConversationDetails(let request as APIRequest),
             .groupConversationList(let request as APIRequest),
             .leaveGroupConversation(let request as APIRequest),
             .joinGroupConversation(let request as APIRequest),
             .openSession(let request as APIRequest),
             .removeUsers(let request as APIRequest),
             .reportMessage(let request as APIRequest):
            return request.parameters
        }
    }

    var path: String {
        switch self {
        case .addUsers(let request):
            return "/chats/group-conversations/\(request.conversationID)/add-users/"
        case .changeOwner(let request):
            return "/chats/group-conversations/\(request.conversationID)/change-owner/"
        case .closeSession:
            return "/chats/sessions/close-session/"
        case .conversationDetails(let request):
            return "/chats/conversations/\(request.conversationID)"
        case .conversationList(let request):
            var path = "/chats/conversations/"

            if let roomIDs = request.chatRoomIDs?.filter({ !$0.isEmpty }) {
                switch roomIDs.count {
                case let count where count > 1:
                    path += "?chat_room_identifier__in=\(roomIDs.joined(separator: ","))"
                case let count where count == 1:
                    if let roomID = roomIDs.first {
                        path += "?chat_room_identifier=\(roomID)"
                    }
                default:
                    break
                }
            }

            return path
        case .createConversation:
            return "/chats/conversations/"
        case .createGroupConversation:
            return "/chats/group-conversations/"
        case .groupConversationDetails(let request):
            return "/chats/group-conversations/\(request.conversationID)/"
        case .groupConversationList(let request):
            var path = "/chats/group-conversations/"
            
            var urlQueryItems: [URLQueryItem] = []
            
            if let chatRoomIDs = request.chatRoomIDs {
                if chatRoomIDs.count > 1 {
                    urlQueryItems.append(.init(name: "chat_room_identifier__in", value: chatRoomIDs.joined(separator: ",")))
                } else if let chatRoomID = chatRoomIDs.first {
                    urlQueryItems.append(.init(name: "chat_room_identifier", value: "\(chatRoomID)"))
                }
            }
            
            if let chatRoomTypes = request.chatRoomTypes {
                if chatRoomTypes.count > 1 {
                    urlQueryItems.append(.init(name: "chat_room_type__in", value: chatRoomTypes.map({ "\($0)" }).joined(separator: ",")))
                } else if let chatRoomType = chatRoomTypes.first {
                    urlQueryItems.append(.init(name: "chat_room_type", value: "\(chatRoomType)"))
                }
            }
            
            if let isPublic = request.isPublic {
                urlQueryItems.append(.init(name: "is_public", value: "\(isPublic)"))
            }
            
            if let userID = request.userID {
                urlQueryItems.append(.init(name: "contains__user_profile_id", value: "\(userID)"))
            }
            
            if !urlQueryItems.isEmpty {
                path += urlQueryItems.intoQuery()
            }

            return path
        case .leaveGroupConversation(let request):
            return "/chats/group-conversations/\(request.chatRoomID)/leave/"
        case .joinGroupConversation(let request):
            return "/chats/group-conversations/\(request.chatRoomID)/join/"
        case .openSession:
            return "/chats/sessions/open-session/"
        case .removeUsers(let request):
            return "/chats/group-conversations/\(request.conversationID)/remove-users/"
        case .reportMessage:
            return "/chats/messages/report-message/"
        }
    }
}
