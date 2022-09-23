//
//  CommunityChatViewModel.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 11/07/2022.
//

import Combine
import UIKit

final class CommunityChatViewModel: BaseViewModel {
    // MARK: - Constants
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
    @Published private(set) var chatRoom: ChatRoomData?
    @Published private(set) var participantsCount: String?
    
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
        switch configurationData {
        case .data(let data):
            chatRoom = data
        case .id(let id):
            state.value = .loading
            
            let request = ChatGroupConversationDetailsRequest(conversationID: id)
            (AtheloAPI.Chat.groupConversationDetails(request: request) as AnyPublisher<ChatRoomData, APIError>)
                .sink { [weak self] result in
                    self?.state.send(result.toViewModelState())
                } receiveValue: { [weak self] value in
                    self?.chatRoom = value
                }.store(in: &cancellables)
        case .roomID(let chatRoomIdentifier):
            state.value = .loading
            
            let request = ChatGroupConversationListRequest(chatRoomIDs: [chatRoomIdentifier])
            (AtheloAPI.Chat.groupConversationList(request: request) as AnyPublisher<ListResponseData<ChatRoomData>, APIError>)
                .mapError({ $0 as Error })
                .tryMap({ value -> ChatRoomData in
                    guard let chatRoom = value.results.first,
                            chatRoom.chatRoomIdentifier.sansApplicationCodeSuffix() == chatRoomIdentifier.sansApplicationCodeSuffix() else {
                        throw ViewModelError.missingData
                    }
                    
                    return chatRoom
                })
                .sink { [weak self] result in
                    self?.state.send(result.toViewModelState())
                } receiveValue: { [weak self] value in
                    self?.chatRoom = value
                }.store(in: &cancellables)
        }
    }
    
    func joinCommunity() {
        guard state.value != .loading,
              let chatRoom = chatRoom, !chatRoom.belongTo else {
            return
        }
        
        let chatRoomID = chatRoom.id
        let request = ChatJoinGroupConversationRequest(chatRoomID: chatRoomID)
        Publishers.NetworkingPublishers.NeverWrappingPublisher(request: Deferred { AtheloAPI.Chat.joinGroupConversation(request: request) })
            .handleEvents(receiveOutput: { _ in
                DispatchQueue.main.async {
//                    NotificationUtility.checkNotificationAuthorizationStatus(in: UIApplication.shared)
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
              let chatRoom = chatRoom, chatRoom.belongTo else {
            return
        }
        
        state.send(.loading)
        
        let chatRoomID = chatRoom.id
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
    
    func sendMessage(_ message: String) -> Bool {
        let trimmedMessage = message.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedMessage.isEmpty,
              let chatRoom = chatRoom, chatRoom.belongTo else {
            return false
        }
        
        ChatUtility.sendMessage(.sendMessage(message: trimmedMessage), chatRoomIdentifier: chatRoom.chatRoomIdentifier)
        
        return true
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
            .compactMap({ $0?.userProfilesCount })
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
    }
    
    // MARK: - Updates
    private func updateRoomDetails() {
        guard let chatRoomID = chatRoom?.chatRoomID else {
            return
        }
        
        let request = ChatGroupConversationDetailsRequest(conversationID: chatRoomID)
        (AtheloAPI.Chat.groupConversationDetails(request: request) as AnyPublisher<ChatRoomData, APIError>)
            .sink { _ in
                /* ... */
            } receiveValue: { [weak self] value in
                self?.chatRoom = value
            }.store(in: &cancellables)
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
