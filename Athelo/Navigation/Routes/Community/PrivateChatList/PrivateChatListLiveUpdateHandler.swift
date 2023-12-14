//
//  PrivateChatListLiveUpdateHandler.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 21/09/2022.
//

import Combine
import Foundation

actor PrivateChatListLiveUpdateHandler {
    // MARK: - Properties
    @Published private(set) var conversationList: [ConversationData]?
    
    private let chatUtility = ChatUtility.privateChatListUtility()
    
    private var chatRooms: [PrivateChatRoomData] = []
    private var contacts: [ContactData] = []
    private var lastMessages: [String: MessagingChatMessage] = [:]
    private var unreadCounts: [String: MessagingChatUnreadCountMessage] = [:]
    
    private var conversationSortClosure: (ConversationData, ConversationData) -> Bool = { lhs, rhs in
        if lhs.lastMessageDate != rhs.lastMessageDate {
            return lhs.lastMessageDate > rhs.lastMessageDate
        }
        
        return lhs.displayName.localizedCaseInsensitiveCompare(rhs.displayName) == .orderedAscending
    }
    
    private var chatCancellables: [AnyCancellable] = []
    
    // MARK: - Initialization
    init() {
        Task {
            await sink()
        }
    }
    
    // MARK: - Public API
    func refresh() async throws {
        try await withThrowingTaskGroup(of: Void.self, body: { group in
            group.addTask {
                try await self.updateChatRooms()
            }
            
            group.addTask {
                if let publisher = IdentityUtility.refreshCaregiverData() {
                    let _ = try await publisher.asAsyncTask()
                }
            }
            
            group.addTask {
                if let publisher = IdentityUtility.refreshPatientData() {
                    let _ = try await publisher.asAsyncTask()
                }
            }
            
            try await group.waitForAll()
        })
        
        updateConversationsList()
        
        let currentTimestamp = Date().toChatTimestamp + 1
        for chatRoomIdentifier in conversationList?.compactMap({ $0.chatRoomIdentifier }) ?? [] {
            await chatUtility.sendMessage(.getHistory(timestamp: currentTimestamp, limit: 1), chatRoomIdentifier: chatRoomIdentifier)
        }
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoChatSessionManager()
        sinkIntoIdentityManager()
    }
    
    private func sinkIntoChatSessionManager() {
        chatCancellables.cancelAndClear()
        
        chatUtility.lastMessagePublisher
            .sink { message in
                Task { [weak self] in
                    await self?.updateConversation(with: message)
                }
            }.store(in: &chatCancellables)
        
        chatUtility.unreadMessagesPublisher
            .sink { message in
                Task { [weak self] in
                    await self?.updateConversation(with: message)
                }
            }.store(in: &chatCancellables)
    }
    
    private func sinkIntoIdentityManager() {
        Publishers.CombineLatest(
            IdentityUtility.$caregivers.map({ $0 ?? [] }),
            IdentityUtility.$patients.map({ $0 ?? [] })
        )
        .map({ $0 + $1 })
        .sink { contacts in
            Task { [weak self] in
                await self?.updateContacts(contacts)
                await self?.updateConversationsList()
            }
        }.store(in: &chatCancellables)
    }
    
    // MARK: - Updates
    private func updateContacts(_ contacts: [ContactData]) async {
        self.contacts = contacts
    }
    
    private func updateChatRooms() async throws {
        let conversationRequests = ChatConversationListRequest()
        chatRooms = try await AtheloAPI.Chat.conversationList(request: conversationRequests).repeating().asAsyncTask()
    }
    
    private func checkChatRoom(with identifier: String, receivedMessage: MessagingChatMessage) async {
        let conversationRequest = ChatConversationListRequest(chatRoomIDs: [identifier])
        guard let chatRoom: PrivateChatRoomData = try? await AtheloAPI.Chat.conversationList(request: conversationRequest).repeating().asAsyncTask().first else {
            return
        }
        
        if !chatRooms.contains(where: { $0.chatRoomIdentifier == identifier }) {
            chatRooms.append(chatRoom)
            
            updateConversationsList()
            updateConversation(with: receivedMessage)
        }
    }
    
    private func updateConversation(with message: MessagingChatMessage) {
        guard let conversationIndex = conversationList?.firstIndex(where: { $0.chatRoomIdentifier == message.chatRoomIdentifier || $0.memberData.id == message.userData?.userProfileID }),
              let oldConversation = conversationList?[safe: conversationIndex] else {
            Task { [weak self] in
                await self?.checkChatRoom(with: message.chatRoomIdentifier, receivedMessage: message)
            }
            
            return
        }
        
        let chatRoomIdentifier = oldConversation.chatRoomIdentifier ?? message.chatRoomIdentifier
        let unreadCountMessage = unreadCounts[chatRoomIdentifier]
        
        let conversation = ConversationData(
            chatRoomIdentifier: oldConversation.chatRoomIdentifier ?? message.chatRoomIdentifier,
            memberData: oldConversation.memberData,
            recentMessage: message,
            unreadCountMessage: unreadCountMessage
        )
        
        var conversations = conversationList
        
        conversations?[conversationIndex] = conversation
        conversations?.sort(by: conversationSortClosure)
        
        lastMessages[chatRoomIdentifier] = message
        conversationList = conversations
        
        Task { [weak self] in
            await self?.chatUtility.sendMessage(.getUnreadMessagesCount, chatRoomIdentifier: chatRoomIdentifier)
        }
    }
    
    private func updateConversation(with message: MessagingChatUnreadCountMessage) {
        guard let conversationIndex = conversationList?.firstIndex(where: { $0.chatRoomIdentifier == message.chatRoomIdentifier }),
            let oldConversation = conversationList?[conversationIndex] else {
            return
        }
        
        let chatRoomIdentifier = oldConversation.chatRoomIdentifier ?? message.chatRoomIdentifier
        let recentMessage = lastMessages[chatRoomIdentifier]
        
        let conversation = ConversationData(
            chatRoomIdentifier: chatRoomIdentifier,
            memberData: oldConversation.memberData,
            recentMessage: recentMessage,
            unreadCountMessage: message
        )
        
        var conversations = conversationList
        
        conversations?[conversationIndex] = conversation
        conversations?.sort(by: conversationSortClosure)
        
        unreadCounts[chatRoomIdentifier] = message
        conversationList = conversations
    }
    
    private func updateConversationsList() {
        var conversationData: [ConversationData] = []
        
        var contacts = contacts
        for chatRoom in chatRooms {
            if let contactIndex = contacts.firstIndex(where: { $0.contactID == chatRoom.userProfile.id }) {
                contacts.remove(at: contactIndex)
                
                let recentMessage = lastMessages[chatRoom.chatRoomIdentifier]
                let unreadCount = unreadCounts[chatRoom.chatRoomIdentifier]
                
                let conversationItem = ConversationData(
                    chatRoomIdentifier: chatRoom.chatRoomIdentifier,
                    memberData: chatRoom.userProfile,
                    recentMessage: recentMessage,
                    unreadCountMessage: unreadCount
                )
                conversationData.append(conversationItem)
            }
        }
        
        conversationData.sort(by: conversationSortClosure)
        
        conversationData.append(contentsOf: contacts.map({
            ConversationData(
                chatRoomIdentifier: nil,
                memberData: ChatRoomMemberData(
                    id: $0.contactID,
                    displayName: $0.contactDisplayName,
                    photo: $0.contactPhoto
                ),
                recentMessage: nil,
                unreadCountMessage: nil
            )
        }).sorted(by: \.displayName.localizedLowercase))
        
        conversationList = conversationData
    }
}
