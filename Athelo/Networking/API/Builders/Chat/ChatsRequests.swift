import Combine
import Foundation

public extension AtheloAPI {
    enum Chat {
        private typealias Builder = ChatRequestBuilder
        
        public static func addUsers(request: ChatAddUsersRequest) -> AnyPublisher<Never, APIError> {
            APIService().request(with: Builder.addUsers(request: request)).eraseToAnyPublisher()
        }
        
        public static func changeOwner(request: ChatChangeOwnerRequest) -> AnyPublisher<Never, APIError> {
            APIService().request(with: Builder.changeOwner(request: request)).eraseToAnyPublisher()
        }
        
        public static func closeSession(request: ChatCloseSessionRequest) -> AnyPublisher<Never, APIError> {
            APIService().request(with: Builder.closeSession(request: request)).eraseToAnyPublisher()
        }
        
        public static func conversationDetails<T: Decodable>(request: ChatConversationDetailsRequest) -> AnyPublisher<T, APIError> {
            APIService().request(with: Builder.conversationDetails(request: request)).eraseToAnyPublisher()
        }
        
        public static func conversationList<T: Decodable>(request: ChatConversationListRequest) -> AnyPublisher<ListResponseData<T>, APIError> {
            APIService().request(with: Builder.conversationList(request: request)).eraseToAnyPublisher()
        }
        
        public static func createConversation<T: Decodable>(request: ChatCreateConversationRequest) -> AnyPublisher<T, APIError> {
            APIService().request(with: Builder.createConversation(request: request)).eraseToAnyPublisher()
        }
        
        public static func createGroupConversation<T: Decodable>(request: ChatCreateGroupConversationRequest) -> AnyPublisher<T, APIError> {
            APIService().request(with: Builder.createGroupConversation(request: request)).eraseToAnyPublisher()
        }
        
        public static func groupConversationDetails<T: Decodable>(request: ChatGroupConversationDetailsRequest) -> AnyPublisher<T, APIError> {
            APIService().request(with: Builder.groupConversationDetails(request: request)).eraseToAnyPublisher()
        }
        
        public static func groupConversationList<T: Decodable>(request: ChatGroupConversationListRequest) -> AnyPublisher<ListResponseData<T>, APIError> {
            APIService().request(with: Builder.groupConversationList(request: request)).eraseToAnyPublisher()
        }
        
        public static func joinGroupConversation(request: ChatJoinGroupConversationRequest) -> AnyPublisher<Never, APIError> {
            APIService().request(with: Builder.joinGroupConversation(request: request)).eraseToAnyPublisher()
        }
        
        public static func leaveGroupConversation(request: ChatLeaveGroupConversationRequest) -> AnyPublisher<Never, APIError> {
            APIService().request(with: Builder.leaveGroupConversation(request: request)).eraseToAnyPublisher()
        }
        
        public static func openSession<T: Decodable>(request: ChatOpenSessionRequest) -> AnyPublisher<T, APIError> {
            APIService().request(with: Builder.openSession(request: request)).eraseToAnyPublisher()
        }
        
        public static func reportMessage(request: ChatReportMessageRequest) -> AnyPublisher<Never, APIError> {
            APIService().request(with: Builder.reportMessage(request: request)).eraseToAnyPublisher()
        }
        
        public static func removeUsers(request: ChatRemoveUsersRequest) -> AnyPublisher<Never, APIError> {
            APIService().request(with: Builder.removeUsers(request: request)).eraseToAnyPublisher()
        }
    }
}
