//
//  PrivateChatListUtility.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 21/09/2022.
//

import Combine
import Foundation

actor PrivateChatListUtility {
    // MARK: - Properties
    private let manager: AtheloMessaging.SessionManager
    
    private let lastMessageSubject = PassthroughSubject<MessagingChatMessage, Never>()
    nonisolated var lastMessagePublisher: AnyPublisher<MessagingChatMessage, Never> {
        lastMessageSubject.eraseToAnyPublisher()
    }
    
    private let unreadMessagesSubject = PassthroughSubject<MessagingChatUnreadCountMessage, Never>()
    nonisolated var unreadMessagesPublisher: AnyPublisher<MessagingChatUnreadCountMessage, Never> {
        unreadMessagesSubject.eraseToAnyPublisher()
    }
    
    private var queuedMessages: [(ChatMessageType, String)] = []
    private var recordedMessages: [String: MessagingChatMessage] = [:]
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - Initialization
    init(manager: AtheloMessaging.SessionManager) {
        self.manager = manager
        
        Task {
            await self.sink()
        }
    }
    
    // MARK: - Public API
    func sendMessage(_ type: ChatMessageType, chatRoomIdentifier: String) {
        guard manager.connectionState == .connected else {
            queuedMessages.append((type, chatRoomIdentifier))
            if manager.connectionState == .idle {
                manager.openSessionIfNecessary()
            }
            
            return
        }
        
        manager.sendMessage(type, chatRoomID: chatRoomIdentifier)
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoSessionManager()
    }
    
    private func sinkIntoSessionManager() {
        manager.connectionStatePublisher
            .first(where: { $0 == .connected })
            .sinkDiscardingValue {
                Task { [weak self] in
                    await self?.pushQueuedMessages()
                }
            }.store(in: &cancellables)
        
        manager.incomingMessagesPublisher
            .sink { [weak self] in
                switch $0.type {
                case .history, .routable:
                    if let message = $0.payload.first as? MessagingChatMessage {
                        Task { [weak self] in
                            await self?.checkLastMessage(message)
                        }
                    }
                case .unreadMessages:
                    if let message = $0.payload.first as? MessagingChatUnreadCountMessage {
                        self?.unreadMessagesSubject.send(message)
                    }
                default:
                    break
                }
            }.store(in: &cancellables)
    }
    
    // MARK: - Updates
    private func checkLastMessage(_ message: MessagingChatMessage) {
        if let lastRecordedMessage = recordedMessages[message.chatRoomIdentifier] {
            guard message.timestamp > lastRecordedMessage.timestamp else {
                return
            }
        }
        
        recordedMessages[message.chatRoomIdentifier] = message
        lastMessageSubject.send(message)
    }
    
    private func pushQueuedMessages() {
        guard !queuedMessages.isEmpty else {
            return
        }
        
        queuedMessages.forEach({
            manager.sendMessage($0.0, chatRoomID: $0.1)
        })
        
        queuedMessages.removeAll()
    }
}
