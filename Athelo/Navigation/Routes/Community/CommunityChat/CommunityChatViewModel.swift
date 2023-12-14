//
//  CommunityChatViewModel.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 11/07/2022.
//

import Combine
import UIKit

protocol CommunityChatData {
    var belongTo: Bool { get }
    var chatRoomIdentifier: String { get }
    var chatRoomID: Int { get }
    var displayName: String? { get }
    var memberCount: Int? { get }
}

final class CommunityChatViewModel: BaseViewModel {
    // MARK: - Constants
    enum NavbarItem: Equatable {
        case avatar(ContactData)
        case options
        
        static func == (lhs: CommunityChatViewModel.NavbarItem, rhs: CommunityChatViewModel.NavbarItem) -> Bool {
            switch (lhs, rhs) {
            case (.avatar(let lhsData), .avatar(let rhsData)):
                return lhsData.contactID == rhsData.contactID
            case (.options, .options):
                return true
            default:
                return false
            }
        }
    }
    
    enum ViewModelError: LocalizedError {
        case missingData
        
        var errorDescription: String? {
            switch self {
            case .missingData:
                return "error.chat.missingchatdata".localized()
            }
        }
    }
    
    private enum Constants {
        static let nonMemberHistoryRefreshDelay: TimeInterval = 5.0
    }
    
    // MARK: - Properties
    @Published private(set) var canSendMessages: Bool = false
    @Published private(set) var chatRoom: CommunityChatData?
    @Published private(set) var displayTitle: String?
    @Published private(set) var navbarItem: NavbarItem?
    @Published private(set) var participantsCount: String?
    @Published private(set) var personData: ContactData?
    
    private let clearInputPromptSubject = PassthroughSubject<Void, Never>()
    var clearInputPromptPublisher: AnyPublisher<Void, Never> {
        clearInputPromptSubject
            .eraseToAnyPublisher()
    }
    
    private let updatePromptSubject = PassthroughSubject<Void, Never>()
    var updatePromptPublisher: AnyPublisher<Void, Never> {
        updatePromptSubject
            .eraseToAnyPublisher()
    }
    
    private var cancellables: [AnyCancellable] = []
    private var timerCancellable: AnyCancellable?
    
    // MARK: - Initialization
    override init() {
        super.init()
        
        sink()
    }
    
    // MARK: - Public API
    func assignConfigurationData(_ configurationData: CommunityChatViewController.ConfigurationData) {
        Task { [weak self] in
            if let personData = configurationData.identityData {
                switch personData {
                case .data(let profileData):
                    self?.personData = profileData
                case .id(let profileID):
                    self?.state.value = .loading
                    
                    do {
                        let request = ProfileDetailsRequest(userID: profileID)
                        let profileData: IdentityProfileData = try await AtheloAPI.Profile.userDetails(request: request).asAsyncTask()
                        
                        self?.personData = profileData
                    } catch {
                        self?.state.value = .error(error: error)
                        return
                    }
                }
            }
            
            if let dataType = configurationData.dataType {
                switch dataType {
                case .data(let data):
                    self?.chatRoom = data
                case .id(let id):
                    if self?.state.value != .loading {
                        self?.state.value = .loading
                    }
                    
                    do {
                        if self?.personData != nil {
                            let request = ChatConversationDetailsRequest(conversationID: id)
                            let chatRoomData: PrivateChatRoomData = try await AtheloAPI.Chat.conversationDetails(request: request).asAsyncTask()
                            
                            self?.chatRoom = chatRoomData
                        } else {
                            let request = ChatGroupConversationDetailsRequest(conversationID: id)
                            let chatRoomData: ChatRoomData = try await AtheloAPI.Chat.groupConversationDetails(request: request).asAsyncTask()
                            
                            self?.chatRoom = chatRoomData
                        }
                        
                        self?.state.value = .loaded
                    } catch {
                        self?.state.value = .error(error: error)
                    }
                case .roomID(let chatRoomIdentifier):
                    if self?.state.value != .loading {
                        self?.state.value = .loading
                    }
                    
                    do {
                        if self?.personData != nil {
                            let request = ChatConversationListRequest(chatRoomIDs: [chatRoomIdentifier])
                            guard let chatRoomData: PrivateChatRoomData = try await AtheloAPI.Chat.conversationList(request: request).asAsyncTask().results.first else {
                                throw ViewModelError.missingData
                            }
                            
                            self?.chatRoom = chatRoomData
                        } else {
                            let request = ChatGroupConversationListRequest(chatRoomIDs: [chatRoomIdentifier])
                            guard let chatRoomData: ChatRoomData = try await AtheloAPI.Chat.groupConversationList(request: request).asAsyncTask().results.first else {
                                throw ViewModelError.missingData
                            }
                            
                            self?.chatRoom = chatRoomData
                        }
                        
                        self?.state.value = .loaded
                    } catch {
                        self?.state.value = .error(error: error)
                    }
                }
            } else {
                if self?.chatRoom == nil, let personData = self?.personData {
                    if self?.state.value != .loading {
                        self?.state.value = .loading
                    }
                    
                    let request = ChatConversationListRequest()
                    
                    do {
                        if let chatRoom: PrivateChatRoomData = try await AtheloAPI.Chat.conversationList(request: request).repeating().asAsyncTask().first(where: { $0.userProfile.id == personData.contactID }) {
                            self?.chatRoom = chatRoom
                        }
                        
                        self?.state.value = .loaded
                    } catch {
                        self?.state.value = .error(error: error)
                    }
                } else {
                    if self?.state.value == .loading {
                        self?.state.value = .loaded
                    }
                }
            }
        }
    }
    
    func joinCommunity() {
        guard state.value != .loading,
              let chatRoom = chatRoom as? ChatRoomData, !chatRoom.belongTo else {
            return
        }
        
        let chatRoomID = chatRoom.chatRoomID
        let request = ChatJoinGroupConversationRequest(chatRoomID: chatRoomID)
        Publishers.NetworkingPublishers.NeverWrappingPublisher(request: Deferred { AtheloAPI.Chat.joinGroupConversation(request: request) })
            .handleEvents(receiveOutput: { _ in
                DispatchQueue.main.async {
                    NotificationUtility.checkNotificationAuthorizationStatus(in: UIApplication.shared)
                }
            })
            .flatMap { _ -> AnyPublisher<ChatRoomData, APIError> in
                let request = ChatGroupConversationDetailsRequest(conversationID: chatRoomID)
                return AtheloAPI.Chat.groupConversationDetails(request: request) as AnyPublisher<ChatRoomData, APIError>
            }
            .sink { [weak self] in
                self?.state.send($0.toViewModelState())
            } receiveValue: { [weak self] in
                ChatUtility.registerChatRoomForPendingGreeting($0.chatRoomIdentifier)
                
                self?.chatRoom = $0
            }.store(in: &cancellables)
    }
    
    func leaveCommunity() {
        guard state.value != .loading,
              let chatRoom = chatRoom as? ChatRoomData, chatRoom.belongTo else {
            return
        }
        
        state.send(.loading)
        
        let chatRoomID = chatRoom.chatRoomID
        let request = ChatLeaveGroupConversationRequest(chatRoomID: chatRoomID)
        Publishers.NetworkingPublishers.NeverWrappingPublisher(request: Deferred { AtheloAPI.Chat.leaveGroupConversation(request: request) })
            .flatMap { _ -> AnyPublisher<ChatRoomData, APIError> in
                let request = ChatGroupConversationDetailsRequest(conversationID: chatRoomID)
                return AtheloAPI.Chat.groupConversationDetails(request: request) as AnyPublisher<ChatRoomData, APIError>
            }
            .sink { [weak self] in
                self?.state.send($0.toViewModelState())
            } receiveValue: { [weak self] in
                ChatUtility.resetChatRoomFromPendingGreeting($0.chatRoomIdentifier)
                self?.updatePromptSubject.send()
                
                self?.chatRoom = $0
            }.store(in: &cancellables)
    }
    
    func sendMessage(_ message: String) {
        let trimmedMessage = message.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedMessage.isEmpty else {
            return
        }
        
        if let profileData = personData, chatRoom == nil {
            state.send(.loading)
            
            let request = ChatCreateConversationRequest(userProfileID: profileData.contactID)
            (AtheloAPI.Chat.createConversation(request: request) as AnyPublisher<CreatedChatData, APIError>)
                .mapError({ $0 as Error })
                .flatMap({ value -> AnyPublisher<PrivateChatRoomData, Error> in
                    let innerRequest = ChatConversationListRequest(chatRoomIDs: [value.chatRoomIdentifier])
                    return (AtheloAPI.Chat.conversationList(request: innerRequest) as AnyPublisher<ListResponseData<PrivateChatRoomData>, APIError>)
                        .tryMap({ value -> PrivateChatRoomData in
                            guard let chatRoom = value.results.first else {
                                throw ViewModelError.missingData
                            }
                            
                            return chatRoom
                        })
                        .eraseToAnyPublisher()
                })
                .sink { [weak self] result in
                    self?.state.send(result.toViewModelState())
                } receiveValue: { [weak self] value in
                    self?.chatRoom = value
                    self?.sendMessage(message)
                }.store(in: &cancellables)

            return
        }
        
        guard !trimmedMessage.isEmpty,
              let chatRoom = chatRoom, chatRoom.belongTo else {
            return
        }
        
        ChatUtility.sendMessage(.sendMessage(message: trimmedMessage), chatRoomIdentifier: chatRoom.chatRoomIdentifier)
        clearInputPromptSubject.send()
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoChatSession()
        sinkIntoOwnSubjects()
    }
    
    private func sinkIntoChatSession() {
        ChatUtility.roomUpdatesSubject
            .filter({ [weak self] in
                self?.chatRoom?.chatRoomIdentifier.sansApplicationCodeSuffix() == $0.sansApplicationCodeSuffix()
            })
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .sinkDiscardingValue { [weak self] in
                self?.updateRoomDetails()
            }.store(in: &cancellables)
    }
    
    private func sinkIntoOwnSubjects() {
        $chatRoom
            .compactMap({ $0?.memberCount })
            .removeDuplicates()
            .map({ value -> String in
                if value <= 0 {
                    return "community.participantcount.none".localized()
                } else if value == 1 {
                    return "community.participantcount.one".localized()
                } else {
                    return "community.participantcount.multiple".localized(arguments: [value])
                }
            })
            .sink { [weak self] value in
                self?.participantsCount = value
            }.store(in: &cancellables)
        
        $chatRoom
            .compactMap({ $0?.belongTo })
            .map({ !$0 })
            .removeDuplicates()
            .sink { [weak self] in
                self?.updateRefreshTimer(withEnabledState: $0)
            }.store(in: &cancellables)
        
        $chatRoom
            .combineLatest($personData)
            .map({ $0?.displayName ?? $1?.contactDisplayName })
            .removeDuplicates()
            .sink { [weak self] in
                self?.displayTitle = $0
            }.store(in: &cancellables)
        
        $chatRoom
            .combineLatest($personData)
            .map({ $1 != nil ? true : $0?.belongTo == true })
            .removeDuplicates()
            .sink { [weak self] in
                self?.canSendMessages = $0
            }.store(in: &cancellables)
        
        $chatRoom
            .combineLatest($personData)
            .map { (chatRoom, personData) -> NavbarItem? in
                if let personData {
                    return .avatar(personData)
                }
                
                return chatRoom?.belongTo == true ? .options : nil
            }
            .removeDuplicates()
            .sink { [weak self] in
                self?.navbarItem = $0
            }.store(in: &cancellables)
    }
    
    // MARK: - Updates
    private func updateRoomDetails() {
        guard let chatRoomID = chatRoom?.chatRoomID else {
            return
        }
        
        if personData != nil {
            let request = ChatConversationDetailsRequest(conversationID: chatRoomID)
            (AtheloAPI.Chat.conversationDetails(request: request) as AnyPublisher<PrivateChatRoomData, APIError>)
                .sink { _ in
                    /* ... */
                } receiveValue: { [weak self] value in
                    self?.chatRoom = value
                }.store(in: &cancellables)
        } else {
            let request = ChatGroupConversationDetailsRequest(conversationID: chatRoomID)
            (AtheloAPI.Chat.groupConversationDetails(request: request) as AnyPublisher<ChatRoomData, APIError>)
                .sink { _ in
                    /* ... */
                } receiveValue: { [weak self] value in
                    self?.chatRoom = value
                }.store(in: &cancellables)
        }
    }
    
    private func updateRefreshTimer(withEnabledState shouldEnable: Bool) {
        timerCancellable?.cancel()
        
        if shouldEnable {
            timerCancellable = Timer.publish(every: Constants.nonMemberHistoryRefreshDelay, on: .main, in: .default)
                .autoconnect()
                .compactMap({ [weak self] _ -> String? in
                    self?.chatRoom?.chatRoomIdentifier
                })
                .sink {
                    ChatUtility.sendMessage(.getHistory(timestamp: Date().toChatTimestamp, limit: 100), chatRoomIdentifier: $0)
                }
        } else {
            timerCancellable = nil
        }
    }
}
