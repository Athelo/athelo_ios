//
//  ChatUtility.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 12/07/2022.
//

import Combine
import Foundation
import SwiftDate

typealias ChatConnectionState = ChatSessionManager.ConnectionState
typealias ChatMessageType = MessagingOutgoingChatSocketMessage.MessageType
typealias ChatSessionManager = AtheloMessaging.SessionManager

final class ChatUtility {
    // MARK: - Constants
    private enum UserDefaultsKey {
        case awaitingGreeting(ChatRoomIdentifier)
        
        private var key: String {
            switch self {
            case .awaitingGreeting(let chatRoomID):
                return "athelo.chat.greeting.\(chatRoomID)"
            }
        }
        
        static func resetValue(for key: UserDefaultsKey) {
            UserDefaults.standard.set(nil, forKey: key.key)
        }
        
        static func setValue<T>(_ value: T, for key: UserDefaultsKey) {
            UserDefaults.standard.set(value, forKey: key.key)
        }
        
        static func value<T>(for key: UserDefaultsKey) -> T? {
            UserDefaults.standard.value(forKey: key.key) as? T
        }
    }
    
    enum Messages {
        static let helloMessage = "Hello everyone!"
    }
    
    // MARK: - Properites
    private static let utility = ChatUtility()
    
    private lazy var manager: ChatSessionManager = ChatSessionManager(monitor: NetworkUtility.utility.networkMonitor)
    
    static var connectionStatePublisher: AnyPublisher<ChatConnectionState, Never> {
        utility.manager.connectionStatePublisher
    }
    static var connectionState: ChatConnectionState {
        utility.manager.connectionState
    }
    
    private let greetingStateUpdateSubject = PassthroughSubject<ChatRoomIdentifier, Never>()
    static var greetingStateUpdatePublisher: AnyPublisher<ChatRoomIdentifier, Never> {
        utility.greetingStateUpdateSubject
            .eraseToAnyPublisher()
    }
    
    private let roomUpdatesPublisher = PassthroughSubject<ChatRoomIdentifier, Never>()
    static var roomUpdatesSubject: AnyPublisher<ChatRoomIdentifier, Never> {
        utility.roomUpdatesPublisher
            .eraseToAnyPublisher()
    }
    
    private var cancellables: [AnyCancellable] = []
    private var systemMessagesCancellable: AnyCancellable?
    
    // MARK: - Public API
    static func connect() {
        guard connectionState == .idle else {
            return
        }
        
        utility.manager.openSessionIfNecessary()
    }
    
    static func listenToSystemMessages() {
        guard utility.systemMessagesCancellable == nil else {
            return
        }
        
        if utility.manager.connectionState == .idle {
            utility.manager.openSessionIfNecessary()
        }
        
        utility.systemMessagesCancellable = utility.manager.incomingMessagesPublisher
            .filter({ $0.type == .systemRoutable })
            .compactMap({ $0.chatRoomIdentifier })
            .sink {
                utility.roomUpdatesPublisher.send($0)
            }
    }
    
    static func logOut() {
        utility.manager.closeExistingSession(purgingTokenData: true)
        
        utility.systemMessagesCancellable?.cancel()
        utility.systemMessagesCancellable = nil
    }
    
    static func registerChatRoomForPendingGreeting(_ chatRoomIdentifier: ChatRoomIdentifier) {
        guard !shouldDisplayPendingGreetingButton(for: chatRoomIdentifier) else {
            return
        }
        
        UserDefaultsKey.setValue(Date(), for: .awaitingGreeting(chatRoomIdentifier))
        
        utility.greetingStateUpdateSubject.send(chatRoomIdentifier)
    }
    
    static func resetChatRoomFromPendingGreeting(_ chatRoomIdentifier: ChatRoomIdentifier) {
        guard shouldDisplayPendingGreetingButton(for: chatRoomIdentifier) else {
            return
        }
        
        UserDefaultsKey.resetValue(for: .awaitingGreeting(chatRoomIdentifier))
        
        utility.greetingStateUpdateSubject.send(chatRoomIdentifier)
    }
    
    static func reconnect() {
        let shouldReconnect: Bool = connectionState == .connected
        
        logOut()
        
        if shouldReconnect {
            utility.manager.openSessionIfNecessary()
        }
    }
    
    static func roomUtility(for chatRoomIdentifier: ChatRoomIdentifier) -> ChatRoomUtility {
        if utility.manager.connectionState == .idle {
            utility.manager.openSessionIfNecessary()
        }
        
        return ChatRoomUtility(manager: utility.manager, chatRoomIdentifier: chatRoomIdentifier)
    }
    
    static func sendMessage(_ type: ChatMessageType, chatRoomIdentifier: ChatRoomIdentifier) {
        if utility.manager.connectionState == .idle {
            utility.manager.connectionStatePublisher
                .first(where: { $0 == .connected })
                .sinkDiscardingValue {
                    sendMessage(type, chatRoomIdentifier: chatRoomIdentifier)
                }.store(in: &utility.cancellables)
            
            utility.manager.openSessionIfNecessary()
            
            return
        }
        
        utility.manager.sendMessage(type, chatRoomID: chatRoomIdentifier)
    }
    
    static func shouldDisplayPendingGreetingButton(for chatRoomIdentifier: ChatRoomIdentifier) -> Bool {
        let key = UserDefaultsKey.awaitingGreeting(chatRoomIdentifier)
        guard let date: Date = UserDefaultsKey.value(for: key) else {
            return false
        }
        
        guard date.dateByAdding(1, .day).date > Date() else {
            UserDefaultsKey.resetValue(for: key)
            return false
        }
        
        return true
    }
}
