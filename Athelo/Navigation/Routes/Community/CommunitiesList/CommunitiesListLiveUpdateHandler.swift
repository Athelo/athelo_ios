//
//  CommunitiesListLiveUpdateHandler.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 19/07/2022.
//

import Combine
import Foundation

actor CommunitiesListLiveUpdateHandler {
    // MARK: - Properties
    @Published nonisolated private(set) var updatedChatRooms: [ChatRoomData]?
    
    private var awaitingChatRooms = Set<ChatRoomIdentifier>()
    private var lockedLiveUpdates: Bool = true
    
    private var updatesCancellable: AnyCancellable?
    
    // MARK: - Public API
    func lockLiveUpdates() {
        guard !lockedLiveUpdates else {
            return
        }
        
        lockedLiveUpdates = true
    }
    
    func unlockLiveUpdates() async {
        guard lockedLiveUpdates else {
            return
        }
        
        lockedLiveUpdates = false
        
        let updatedChatRooms = Array(awaitingChatRooms)
        awaitingChatRooms.removeAll()
        
        await requestDetails(for: updatedChatRooms)
    }
    
    func registerListeners(forced: Bool = false) {
        if !forced {
            guard updatesCancellable == nil else {
                return
            }
        }
        
        updatesCancellable?.cancel()
        updatesCancellable = ChatUtility.roomUpdatesSubject
            .sink(receiveValue: { value in
                Task { [weak self] in
                    await self?.handleNewUpdate(for: value)
                }
            })
    }
    
    // MARK: - Updates
    private func handleNewUpdate(for chatRoomIdentifier: ChatRoomIdentifier) async {
        if lockedLiveUpdates {
            awaitingChatRooms.insert(chatRoomIdentifier)
        } else {
            await requestDetails(for: [chatRoomIdentifier])
        }
    }
    
    private func requestDetails(for chatRoomIdentifiers: [ChatRoomIdentifier]) async {
        let request = ChatGroupConversationListRequest(chatRoomIDs: chatRoomIdentifiers, isPublic: true)
        let publisher = Publishers.NetworkingPublishers.ListRepeatingPublisher(initialRequest: Deferred { AtheloAPI.Chat.groupConversationList(request: request) as AnyPublisher<ListResponseData<ChatRoomData>, APIError> })
        
        let results = try? await publisher.asAsyncTask()
        
        updatedChatRooms = results
    }
}
