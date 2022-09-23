//
//  ChatRoomUtility.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 12/07/2022.
//

import Combine
import Foundation

final class ChatRoomUtility {
    // MARK: - Constants
    static let chatRoomQueue = DispatchQueue(label: "com.athelo.chatroom.messages")
    
    private enum Constants {
        static let messagesPageSize: Int = 100
    }
    
    // MARK: - Properties
    @Published private(set) var messages: [MessagingChatMessage]?
    
    private let manager: AtheloMessaging.SessionManager
    let roomIdentifier: ChatRoomIdentifier
    
    private let historyRequestPingbackSubject = PassthroughSubject<HistoryRequestPingbackType, Never>()
    var historyRequestPingbackPublisher: AnyPublisher<HistoryRequestPingbackType, Never> {
        historyRequestPingbackSubject
            .eraseToAnyPublisher()
    }
    
    private var lastKnownReadMessage: MessagingChatMessage?
    private var maintainedMessageList: [MessagingChatMessage] = [] {
        didSet {
            messages = maintainedMessageList
        }
    }
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - Initialization
    init(manager: ChatSessionManager, chatRoomIdentifier: ChatRoomIdentifier) {
        self.manager = manager
        self.roomIdentifier = chatRoomIdentifier
        
        sink()
        updateMessagesWithLatestHistoricalData()
    }
    
    // MARK: - Public API
    func fetchMostRecentMessages() {
        updateMessagesWithMostRecentData()
    }
    
    func updateMessagesHistory() {
        updateMessagesWithLatestHistoricalData()
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoChatUtility()
        sinkIntoSessionManager()
    }
    
    private func sinkIntoChatUtility() {
        ChatUtility.connectionStatePublisher
            .filter({ $0 != .connected })
            .flatMap({ _ -> AnyPublisher<ChatConnectionState, Never> in
                ChatUtility.connectionStatePublisher
                    .filter({ $0 == .connected })
                    .eraseToAnyPublisher()
            })
            .filter({ [weak self] _ in
                if let messagesCount = self?.maintainedMessageList.count {
                    return messagesCount == 0
                }
                
                return true
            })
            .first()
            .ignoreOutput()
            .sink(receiveCompletion: { [weak self] _ in
                self?.updateMessagesWithLatestHistoricalData()
            }).store(in: &cancellables)
    }
    
    private func sinkIntoSessionManager() {
        manager.incomingMessagesPublisher
            .sink { [weak self] in
                self?.handleIncomingChatMessage($0)
            }.store(in: &cancellables)
    }
    
    // MARK: - Updates
    private func forwardHistoryRequest(at timestamp: Int64) {
        manager.sendMessage(.getLastMessagesRead, chatRoomID: roomIdentifier)
        manager.sendMessage(.getHistory(timestamp: timestamp, limit: Constants.messagesPageSize), chatRoomID: roomIdentifier)
    }
    
    private func updateMessagesWithMostRecentData() {
        forwardHistoryRequest(at: Date().toChatTimestamp)
    }
    
    private func updateMessagesWithLatestHistoricalData() {
        historyRequestPingbackSubject.send(.historyRequested)
        
        let timestamp: Int64 = maintainedMessageList.first?.incomingChatMessageID ?? Int64(Date().toChatTimestamp)
        forwardHistoryRequest(at: timestamp)
    }
    
    // MARK: - Incoming messages handling
    private func handleIncomingChatMessage(_ chatMessage: MessagingIncomingChatSocketMessage) {        
        guard chatMessage.chatRoomIdentifier == roomIdentifier else {
            return
        }
        
        switch chatMessage.type {
        case .error, .lastMessage, .unreadMessages:
            break
        case .history:
            if let messages = chatMessage.payload as? [MessagingChatMessage] {
                let pingbackMessage: HistoryRequestPingbackType = messages.isEmpty ? .historyPayloadMissing : .historyPayloadAvailable
                historyRequestPingbackSubject.send(pingbackMessage)
                
                handleIncomingHistoryPayload(messages)
            }
        case .messageRead, .messagesRead:
            if let messages = chatMessage.payload as? [MessagingChatMessage] {
                handleIncomingMessagesReadPayload(messages)
            }
        case .routable:
            if let message = chatMessage.payload.first as? MessagingChatMessage {
                handleIncomingRoutablePayload(message)
            }
        case .systemRoutable:
            if let messages = chatMessage.payload as? [MessagingChatSystemMessage] {
                handleIncomingSystemRoutablePayload(messages.map({ MessagingChatMessage(from: $0) }))
            }
        }
    }
    
    private func handleIncomingHistoryPayload(_ messages: [MessagingChatMessage]) {
        ChatRoomUtility.chatRoomQueue.async { [weak self] in
            self?.updateMaintainedItemsWithMessages(messages)
        }
    }
    
    private func handleIncomingRoutablePayload(_ message: MessagingChatMessage) {
        ChatRoomUtility.chatRoomQueue.async { [weak self] in
            self?.updateMaintainedItemsWithMessages([message])
        }
        
        if message.userIdentifier.sansApplicationCodeSuffix() == IdentityUtility.userData?.user?.username.sansApplicationCodeSuffix() {
            ChatUtility.resetChatRoomFromPendingGreeting(roomIdentifier)
        }
    }
    
    private func handleIncomingSystemRoutablePayload(_ messages: [MessagingChatMessage]) {
        ChatRoomUtility.chatRoomQueue.async { [weak self] in
            self?.updateMaintainedItemsWithMessages(messages)
        }
    }
    
    private func handleIncomingMessagesReadPayload(_ messages: [MessagingChatMessage]) {
        ChatRoomUtility.chatRoomQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            
            let userID = IdentityUtility.userData?.user?.username.sansApplicationCodeSuffix()
            guard let validMessage = messages.filter({
                $0.userIdentifier.sansApplicationCodeSuffix() == userID
                    && $0.chatRoomIdentifier == self.roomIdentifier
            }).sorted(by: { $0.timestamp < $1.timestamp }).last else {
                return
            }

            if let currentlyKnownLastMessage = self.lastKnownReadMessage {
                guard validMessage.timestamp > currentlyKnownLastMessage.incomingChatMessageID else {
                    return
                }
            }
            
            self.lastKnownReadMessage = validMessage
        }
    }
    
    private func updateMaintainedItemsWithMessages(_ messages: [MessagingChatMessage]) {
        dispatchPrecondition(condition: .onQueue(ChatRoomUtility.chatRoomQueue))
        
        let validMessages = messages.filter({ $0.incomingChatRoomID == roomIdentifier })
        var messageIDs = Set<String>()
        
        messageIDs.formUnion(maintainedMessageList.map({ $0.messageID }))
        messageIDs.formUnion(validMessages.map({ $0.messageID }))
        
        var roomMessages: [MessagingChatMessage] = []
        for message in maintainedMessageList + validMessages {
            let messageID = message.messageID
            if messageIDs.contains(messageID) {
                messageIDs.remove(messageID)
                roomMessages.append(message)
            }
        }

        let sortedMessages = roomMessages.sorted(by: { $0.incomingChatMessageID < $1.incomingChatMessageID })
        maintainedMessageList = sortedMessages
    }
}

extension ChatRoomUtility {
    enum HistoryRequestPingbackType {
        /// A request for (any) number of chat messages has been sent.
        case historyRequested
        /// A response of history type has been received which contained at least one message.
        case historyPayloadAvailable
        /// A response of history type has been received which didn't contain any message.
        case historyPayloadMissing
    }
}
