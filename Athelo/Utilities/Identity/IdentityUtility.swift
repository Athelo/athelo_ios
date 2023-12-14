//
//  UserStore.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 31/05/2022.
//

import Combine
import Foundation

enum ThirdPartyAuthenticationPlatform {
    case apple
    case google
}

protocol ThirdPartyAuthenticationError: LocalizedError {
    var isSheetDismissedError: Bool { get }
}

enum SignInHandlerState: Equatable {
    case initial
    case loading
    case loaded(token: IdentityTokenData, email: String?)
    case error(error: Error)
    
    static func ==(lhs: Self, rhs: Self) -> Bool {
        switch((lhs, rhs)) {
        case (.error, .error):
            return true
        case (.initial, .initial):
            return true
        case (.loaded, .loaded):
            return true
        case (.loading, .loading):
            return true
        default:
            break
        }

        return false
    }
}

@dynamicMemberLookup final class IdentityUtility: NSObject {
    // MARK: - Constants
    enum ProfileError: LocalizedError {
        case missingAppleCredentialsData
        
        var errorDescription: String? {
            switch self {
            case .missingAppleCredentialsData:
                return "error.apple.revoked".localized()
            }
        }
    }
    
    fileprivate struct LoginData: Codable {
        enum Method: Hashable, Codable {
            case email
            case apple
            case google
            case facebook
            case twitter
        }
        
        private static let storeKey = "athelo.login.data"
        
        let email: String?
        let method: Method
        
        static func clear() {
            UserDefaults.standard.removeObject(forKey: storeKey)
        }
        
        func store() {
            guard let data = try? JSONEncoder().encode(self) else {
                return
            }
            
            UserDefaults.standard.set(data, forKey: LoginData.storeKey)
        }
        
        static func storedData() -> LoginData? {
            guard let data = UserDefaults.standard.object(forKey: storeKey) as? Data,
                  let loginData = try? JSONDecoder().decode(LoginData.self, from: data) else {
                return nil
            }
            
            return loginData
        }
    }
    
    // MARK: - Properties
    private static let shared = IdentityUtility()
    
    private let roleUtility = IdentityRoleUtility()
    static var activeUserRole: ActiveUserRole? {
        shared.roleUtility.activeRole
    }
    
    private let userDataSubject = CurrentValueSubject<IdentityProfileData?, Never>(nil)
    static var userDataPublisher: AnyPublisher<IdentityProfileData?, Never> {
        shared.userDataSubject.eraseToAnyPublisher()
    }
    static var userData: IdentityProfileData? {
        shared.userDataSubject.value
    }
    
    private let authenticationMethodsSubject = CurrentValueSubject<[IdentityAuthenticationMethod]?, Never>(nil)
    static var authenticationMethods: [IdentityAuthenticationMethod]? {
        shared.authenticationMethodsSubject.value
    }
    
    private lazy var signInWithAppleHandler = {
        IdentitySignInWithAppleHandler()
    }()
    private lazy var signInWithGoogleHandler = {
        IdentitySignInWithGoogleHandler()
    }()
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - Subscripts
    static subscript<T>(dynamicMember keyPath: KeyPath<IdentityRoleUtility, T>) -> T {
        shared.roleUtility[keyPath: keyPath]
    }
    
    // MARK: - Initialization
    private override init() {
        super.init()
        
        sink()
    }
    
    // MARK: - Public API
    static func createAccount(name: String) -> AnyPublisher<IdentityProfileData, Error> {
        guard APIEnvironment.hasTokenData() else {
            return Fail(error: APIError.missingCredentials)
                .mapError({ $0 as Error })
                .eraseToAnyPublisher()
        }
        
        let loginData = LoginData.storedData()
        guard let knownEmail = loginData?.email else {
            var error: Error = APIError.missingCredentials
            if loginData?.method == .apple {
                error = ProfileError.missingAppleCredentialsData
                shared.clearUserData()
            }
            
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
        
        let request = ProfileCreateRequest(email: knownEmail, additionalParams: [
            "display_name": name
        ])
        
        return (AtheloAPI.Profile.create(request: request) as AnyPublisher<IdentityProfileData, APIError>)
            .mapError({ $0 as Error })
            .flatMap({ _ in refreshUserDetails() })
            .handleEvents(receiveOutput: { value in
                LoginData.clear()
            })
            .eraseToAnyPublisher()
    }
    
    static func deleteAccount() -> AnyPublisher<Never, Error>  {
        guard APIEnvironment.hasTokenData() else {
            return Fail(error: APIError.missingCredentials)
                .mapError({ $0 as Error })
                .eraseToAnyPublisher()
        }
        
        return AtheloAPI.Profile.deleteAccount()
            .handleEvents(receiveCompletion: {
                if case .finished = $0 {
                    LoginData.clear()
                    logOut()
                }
            })
            .mapError({ $0 as Error })
            .eraseToAnyPublisher()
    }
    
    static func login(email: String, password: String) -> AnyPublisher<IdentityProfileData, Error> {
        let loginRequest = AuthenticationLoginRequest(email: email, password: password)
        return wrapLoginPublisher(
            (AtheloAPI.Authentication.login(request: loginRequest) as AnyPublisher<IdentityTokenDataWrapper, APIError>)
                .map({ $0.tokenData })
                .mapError({ $0 as Error })
                .eraseToAnyPublisher(),
            loginMethod: .email,
            email: email
        )
    }
    
    static func logOut() {
        PreferencesStore.setCommunitiesLandingAsDisplayed(false)
        shared.clearUserData()
    }
    
    static func register(email: String, password: String, confirmPassword: String) -> AnyPublisher<Never, Error> {
        let request = AuthenticationRegisterRequest(email: email, password: password, repeatedPassword: confirmPassword)
        
        return AtheloAPI.Authentication.register(request: request)
            .tryMap({ value -> Void in
                try APIEnvironment.setUserToken(value.tokenData)
            })
            .handleEvents(receiveOutput: { _ in
                let loginData = LoginData(email: email, method: .email)
                loginData.store()
            })
            .mapError({ $0 as Error })
            .ignoreOutput()
            .eraseToAnyPublisher()
    }
    
    static func signInWithThirdPartyPlatform(_ platform: ThirdPartyAuthenticationPlatform) -> AnyPublisher<IdentityProfileData, Error> {
        switch platform {
        case .apple:
            return wrapThirdPartyLoginPublisher(shared.signInWithAppleHandler.performLoginAttempt(), loginMethod: .apple)
        case .google:
            return wrapThirdPartyLoginPublisher(shared.signInWithGoogleHandler.performLoginAttempt(), loginMethod: .google)
        }
    }
    
    static func switchActiveRole(_ activeRole: ActiveUserRole?) {
        guard userData != nil else {
            return
        }
        
        if let activeRole {
            shared.roleUtility.changeActiveRole(activeRole)
        } else {
            shared.roleUtility.resetRoleForActiveUser()
        }
    }
    
    @discardableResult static func refreshCaregiverData() -> AnyPublisher<[ContactData], Error>? {
        guard userData != nil else {
            return nil
        }
        
        return shared.roleUtility.updateCaregiverDataForActiveUser()
    }
    
    @discardableResult static func refreshPatientData() -> AnyPublisher<[ContactData], Error>? {
        guard userData != nil else {
            return nil
        }
        
        return shared.roleUtility.updatePatientDataForActiveUser()
    }
    
    static func refreshUserDetails() -> AnyPublisher<IdentityProfileData, Error> {
        guard APIEnvironment.hasTokenData() else {
            return Fail(error: APIError.missingCredentials)
                .mapError({ $0 as Error })
                .eraseToAnyPublisher()
        }
        
        return (AtheloAPI.Profile.currentUserDetails() as AnyPublisher<IdentityProfileData, APIError>)
            .handleEvents(receiveOutput: { value in
                shared.userDataSubject.send(value)
            })
            .eraseToAnyPublisher()
            .flatMap({ value -> AnyPublisher<IdentityProfileData, APIError> in
                (AtheloAPI.Profile.authorizationMethods() as AnyPublisher<[IdentityAuthenticationMethod], APIError>)
                    .handleEvents(receiveOutput: { methods in
                        shared.authenticationMethodsSubject.send(methods)
                    })
                    .map({ _ in value })
                    .eraseToAnyPublisher()
            })
            .mapError({ $0 as Error })
            .eraseToAnyPublisher()
    }
    
    static func updateUserProfile(using params: [String: Any]) -> AnyPublisher<IdentityProfileData, Error> {
        guard APIEnvironment.hasTokenData(),
              let userID = shared.userDataSubject.value?.id else {
            return Fail(error: APIError.missingCredentials)
                .mapError({ $0 as Error })
                .eraseToAnyPublisher()
        }
        
        let request = ProfileUpdateRequest(userID: userID, params: params)
        return (AtheloAPI.Profile.update(request: request) as AnyPublisher<IdentityProfileData, APIError>)
            .handleEvents(receiveOutput: { value in
                shared.userDataSubject.send(value)
            })
            .mapError({ $0 as Error })
            .eraseToAnyPublisher()
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoOwnSubjects()
    }
    
    private func sinkIntoOwnSubjects() {
        userDataSubject
            .sink { [weak self] in
                self?.roleUtility.updateActiveUser($0)
            }.store(in: &cancellables)
    }
    
    // MARK: - Updates
    private static func checkChatRoomsAvailability() {
        guard let userID = userData?.id else {
            return
        }
        
        let communitiesRequest = ChatGroupConversationListRequest(isPublic: true, userID: userID)
        let privateConversationsRequest = ChatConversationListRequest()
        
        Task {
            let communities = try? await (AtheloAPI.Chat.groupConversationList(request: communitiesRequest) as AnyPublisher<ListResponseData<ChatRoomData>, APIError>).asAsyncTask()
            let privateConversations = try? await (AtheloAPI.Chat.conversationList(request: privateConversationsRequest) as AnyPublisher<ListResponseData<PrivateChatRoomData>, APIError>).asAsyncTask()
            
            if communities?.results.isEmpty == false || privateConversations?.results.isEmpty == false {
                ChatUtility.connect()
                NotificationUtility.checkNotificationAuthorizationStatus(requestingStatus: true)
            }
        }
    }
    
    private func clearUserData() {
        ChatUtility.logOut()
        APIEnvironment.clearUserToken()
        
        LoginData.clear()
        
        authenticationMethodsSubject.send(nil)
        userDataSubject.send(nil)
        
        roleUtility.clearCachedData()
    }
    
    private func updateProfileData(with profileData: IdentityProfileData) {
        userDataSubject.send(profileData)
    }
    
    // MARK: - Stream wrappers
    private static func wrapLoginPublisher(_ loginPublisher: AnyPublisher<IdentityTokenData, Error>, loginMethod: LoginData.Method, email: String? = nil) -> AnyPublisher<IdentityProfileData, Error> {
        loginPublisher
            .handleEvents(receiveOutput: {
                try? APIEnvironment.setUserToken($0)
            })
            .flatMap({ _ -> AnyPublisher<IdentityProfileData, Error> in
                refreshUserDetails()
                    .mapError({ error -> Error in
                        if case .httpError(let code, _) = (error as? APIError), code == 403 {
                            return APIError.missingCredentials
                        }
                        
                        return error
                    })
                    .eraseToAnyPublisher()
            })
            .flatMap({ value -> AnyPublisher<IdentityProfileData, Error> in
                let request = ChatGroupConversationListRequest(isPublic: true)
                return (AtheloAPI.Chat.groupConversationList(request: request) as AnyPublisher<ListResponseData<ChatRoomData>, APIError>)
                    .handleEvents(receiveOutput: { innerValue in
                        if innerValue.results.contains(where: { $0.belongTo }) {
                            PreferencesStore.setCommunitiesLandingAsDisplayed(true)
                        }
                    })
                    .map({ _ in value })
                    .replaceError(with: value)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            })
            .handleEvents(receiveCompletion: { result in
                if case .failure(let error) = result {
                    if case .missingCredentials = (error as? APIError) {
                        let loginData = LoginData(email: email, method: loginMethod)
                        loginData.store()
                        
                        return
                    }
                    
                    shared.clearUserData()
                }
                
                checkChatRoomsAvailability()
            })
            .mapError({ $0 as Error })
            .eraseToAnyPublisher()
    }
    
    private static func wrapThirdPartyLoginPublisher(_ thirdPartyLoginPublisher: AnyPublisher<SignInHandlerState, Never>, loginMethod: LoginData.Method) -> AnyPublisher<IdentityProfileData, Error> {
        thirdPartyLoginPublisher
            .compactMap({ value -> Result<(IdentityTokenData, String?), Error>? in
                switch value {
                case .initial, .loading:
                    return nil
                case .loaded(let token, let email):
                    return .success((token, email))
                case .error(let error):
                    return .failure(error)
                }
            })
            .flatMap({ result -> AnyPublisher<IdentityProfileData, Error> in
                switch result {
                case .success(let value):
                    return wrapLoginPublisher(
                        Just(value.0)
                            .setFailureType(to: Error.self)
                            .eraseToAnyPublisher(),
                        loginMethod: loginMethod,
                        email: value.1
                    )
                    .mapError({ error in
                        if case .missingCredentials = (error as? APIError) {
                            return AuthenticationPingError()
                        }
                        
                        return error
                    })
                    .eraseToAnyPublisher()
                case .failure(let error):
                    return Fail(error: error)
                        .eraseToAnyPublisher()
                }
            })
            .eraseToAnyPublisher()
    }
}
