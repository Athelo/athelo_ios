//
//  File.swift
//  
//
//  Created by Krzysztof Jabłoński on 28/06/2022.
//

import Combine
import Foundation
import Network
import UIKit

public extension AtheloMessaging {
    final class SessionManager: NSObject {
        // MARK: - Constants
        private typealias Environment = APIEnvironment
        
        // MARK: - Properties
        private let validNetworkPathSubject = CurrentValueSubject<Bool, Never>(false)
        private lazy var networkMonitor: NWPathMonitor = {
            let monitor = NWPathMonitor()

            let queue = DispatchQueue(label: "com.networking.messaging.network.monitor")
            monitor.start(queue: queue)

            return monitor
        }()
        
        private let errorSubject = CurrentValueSubject<Error?, Never>(nil)
        public var errorPublisher: AnyPublisher<Error, Never> {
            errorSubject
                .compactMap({ $0 })
                .eraseToAnyPublisher()
        }
        
        private let incomingMessagesSubject = CurrentValueSubject<MessagingIncomingChatSocketMessage?, Never>(nil)
        public var incomingMessagesPublisher: AnyPublisher<MessagingIncomingChatSocketMessage, Never> {
            incomingMessagesSubject
                .compactMap({ $0 })
                .eraseToAnyPublisher()
        }
        
        private let state = CurrentValueSubject<State, Never>(.idle)
        public var connectionStatePublisher: AnyPublisher<ConnectionState, Never> {
            state
                .map({ $0.connectionState })
                .removeDuplicates()
                .eraseToAnyPublisher()
        }
        public var connectionState: ConnectionState {
            state.value.connectionState
        }
        
        private var socket: URLSessionWebSocketTask?
        
        private var cancellables: [AnyCancellable] = []
        
        // MARK: - Initialization
        public init(monitor: NWPathMonitor? = nil) {
            super.init()
            
            if let monitor = monitor {
                self.networkMonitor = monitor
            }
            
            networkMonitor.pathUpdateHandler = { [weak self] in
                self?.validNetworkPathSubject.send($0.status == .satisfied)
            }
        }
        
        // MARK: - Public API
        public func closeExistingSession(purgingTokenData: Bool = false) {
            if purgingTokenData {
                if let token = Environment.storedChatToken() {
                    Task {
                        let request = ChatCloseSessionRequest(token: token)
                        try await AtheloAPI.Chat.closeSession(request: request).asAsyncTask()
                    }
                }
                
                Environment.clearChatToken()
            }
            
            closeChatSession()
        }
        
        public func openSessionIfNecessary() {
            retrieveToken()
        }
        
        public func sendMessage(_ messageType: MessagingOutgoingChatSocketMessage.MessageType, chatRoomID: String) {
            sendMessage(.init(type: messageType, chatRoomID: chatRoomID))
        }
        
        public func sendMessage(_ message: MessagingOutgoingChatSocketMessage) {
            guard state.value == .connected,
                  socket != nil else {
                return
            }
            
            do {
                let json = try message.toJSONData()
                debugPrint(#fileID, #function, json)
                
                socket?.send(.data(json), completionHandler: { [weak self] error in
                    if let error = error {
                        self?.errorSubject.send(error)
                    }
                })
            } catch {
                errorSubject.send(error)
            }
        }
        
        // MARK: - Updates
        private func closeChatSession() {
            guard let socket = socket,
                  state.value == .connected else {
                return
            }
            
            socket.cancel()
        }
        
        private func handleMessage(with data: Data) {
            do {
                let decoder = JSONDecoder()
                let message = try decoder.decode(MessagingIncomingChatSocketMessage.self, from: data)

                incomingMessagesSubject.send(message)
            } catch let error {
                debugPrint(#fileID, #function, error)
            }
        }
        
        private func openChatSession() {
            guard let token = Environment.storedChatToken(), !token.isEmpty,
                  let servicePath = try? Environment.storedChatServicePath(),
                  let serviceURL = URL(string: servicePath),
                  socket == nil else {
                return
            }
            
            state.value = .creatingSession
            
            var request = URLRequest(url: serviceURL)
            request.setValue(token, forHTTPHeaderField: "X-TOKEN")
            
            let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
            let socket = session.webSocketTask(with: request)
            
            socket.resume()
        }
        
        private func registerForNextMessage() {
            socket?.receive(completionHandler: { [weak self] result in
                switch result {
                case .success(let message):
                    switch message {
                    case .data(let data):
                        self?.handleMessage(with: data)
                    case .string(let string):
                        if let data = string.data(using: .utf8) {
                            self?.handleMessage(with: data)
                        }
                    @unknown default:
                        break
                    }
                case .failure(let error):
                    self?.errorSubject.send(error)
                }
                
                self?.registerForNextMessage()
            })
        }
        
        private func retrieveToken() {
            guard Environment.hasTokenData(for: .userToken, String.self) else {
                return
            }
            
            if Environment.hasTokenData(for: .chatToken, String.self) {
                openChatSession()
                return
            }
            
            guard state.value == .idle,
                  let deviceID = UIDevice.current.identifierForVendor else {
                return
            }
            
            state.value = .retrievingToken
            
            #if targetEnvironment(simulator)
            let request = ChatOpenSessionRequest(deviceID: deviceID.uuidString)
            #else
            let fcmToken = APIEnvironment.storedFCMToken()
            let request = ChatOpenSessionRequest(deviceID: deviceID.uuidString, fcmToken: fcmToken)
            #endif
            
            (AtheloAPI.Chat.openSession(request: request) as AnyPublisher<MessagingChatTokenData, APIError>)
                .map({ $0.token })
                .sink { [weak self] result in
                    if case .failure(let error) = result {
                        self?.errorSubject.send(error)
                        self?.state.value = .idle
                    }
                } receiveValue: { [weak self] value in
                    do {
                        try APIEnvironment.setChatToken(value)
                        self?.state.value = .tokenRetrieved
                        
                        self?.openChatSession()
                    } catch {
                        self?.errorSubject.send(error)
                        self?.state.value = .idle
                    }
                }.store(in: &cancellables)
        }
    }
}

public extension AtheloMessaging.SessionManager {
    /// Describes current connection state of session manager.
    enum ConnectionState {
        /// Session maneger is awaiting reconnection request.
        case idle
        /// Session manager is currently attempting to establish conenction with chat server.
        case connecting
        /// Session manager is connected to chat server.
        case connected
        /// Session manager is currently cleaning up after last session with chat server.
        case disconnecting
    }
    
    /// Describes state in which session manager is currently in.
    enum State {
        /// Session manager does nothing and is awaiting session opening request.
        case idle
        /// Session manager attempts to retrieve session token.
        case retrievingToken
        /// Session manager has retreived session token, but did not perform any attempt to open a session.
        case tokenRetrieved
        /// Session manager is currently atttempting to open a session.
        case creatingSession
        /// Session manager has an active session open. Chat messages can be sent and retrieved.
        case connected
        /// Session manager is currenly cleaning up and closing an existing session.
        case disconnecting
        
        var connectionState: ConnectionState {
            switch self {
            case .connected:
                return .connected
            case .creatingSession, .retrievingToken, .tokenRetrieved:
                return .connecting
            case .disconnecting:
                return .disconnecting
            case .idle:
                return .idle
            }
        }
    }
}

extension AtheloMessaging.SessionManager: URLSessionWebSocketDelegate {
    public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        if state.value == .creatingSession, Environment.hasTokenData(for: .chatToken, String.self) {
            socket = webSocketTask
            
            state.value = .connected
            registerForNextMessage()
        } else {
            socket?.cancel()
            socket = nil
        }
    }
    
    public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        debugPrint(#fileID, #function, closeCode)
        
        socket?.cancel()
        socket = nil
        
        state.value = .idle
        
        retrieveToken()
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            errorSubject.send(error)
        }
        
        socket?.cancel()
        socket = nil
        
        state.value = .idle
        
        retrieveToken()
    }
}
