import Combine
import Foundation

public extension AtheloAPI {
    private typealias Builder = ContactsRequestBuilder
    
    enum Contacts {
        public static func friends<T: Decodable>() -> AnyPublisher<[T], APIError> {
            APIService().request(with: Builder.friends).eraseToAnyPublisher()
        }

        public static func search<T: Decodable>(request: ContactsSearchRequest) -> AnyPublisher<ListResponseData<T>, APIError> {
            APIService().request(with: Builder.search(request: request)).eraseToAnyPublisher()
        }

        public static func invitation<T: Decodable>(request: ContactsInvitationRequest) -> AnyPublisher<T, APIError> {
            APIService().request(with: Builder.invitation(request: request)).eraseToAnyPublisher()
        }

        public static func invitations<T: Decodable>(request: ContactsInvitationListRequest) -> AnyPublisher<ListResponseData<T>, APIError> {
            APIService().request(with: Builder.invitationList(request: request)).eraseToAnyPublisher()
        }

        public static func removeFriend(request: ContactsRemoveFriendRequest) -> AnyPublisher<Never, APIError> {
            APIService().request(with: Builder.removeFriend(request: request)).eraseToAnyPublisher()
        }

        public static func sendInvite(request: ContactsSendInviteRequest) -> AnyPublisher<Never, APIError> {
            APIService().request(with: Builder.sendInvite(request: request)).eraseToAnyPublisher()
        }

        public static func updateInvite(request: ContactsUpdateInviteRequest) -> AnyPublisher<Never, APIError> {
            APIService().request(with: Builder.updateInvite(request: request)).eraseToAnyPublisher()
        }

        public static func report(request: ContactsReportProfileRequest) -> AnyPublisher<Never, APIError> {
            APIService().request(with: Builder.report(request: request)).eraseToAnyPublisher()
        }
    }
}
