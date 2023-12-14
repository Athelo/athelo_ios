//
//  PrivateChatListViewModel.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 21/09/2022.
//

import Combine
import UIKit

final class PrivateChatListViewModel: BaseViewModel {
    // MARK: - Properties
    let conversationsModel = ConversationListModel(conversations: [])
    
    private let liveUpdateHandler = PrivateChatListLiveUpdateHandler()
//
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - Initialization
    override init() {
        super.init()
        
        sink()
    }
    
    // MARK: - Public API
    func refresh() {
        guard state.value != .loading else {
            return
        }
        
        state.send(.loading)
        
        Task { [weak self] in
            do {
                try await self?.liveUpdateHandler.refresh()
                self?.state.send(.loaded)
            } catch {
                self?.state.send(.error(error: error))
            }
        }
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoLiveUpdateHandler()
    }
    
    private func sinkIntoLiveUpdateHandler() {
        Task { [weak self] in
            guard let self = self else {
                return
            }
            
            await self.liveUpdateHandler.$conversationList
                .compactMap({ $0 })
                .debounce(for: 0.25, scheduler: DispatchQueue.main)
                .sink { [weak self] in
                    self?.conversationsModel.updateConversations($0)
                }.store(in: &self.cancellables)
        }
    }
}
