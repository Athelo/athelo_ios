//
//  PrivateChatListViewController.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 21/09/2022.
//

import Combine
import UIKit

final class PrivateChatListViewController: BaseViewController {
    // MARK: - Properties
    private let viewModel = PrivateChatListViewModel()
    private var router: PrivateChatListRouter?
    
    private var conversationListView: ConversationListView?
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        sink()
        
        viewModel.refresh()
    }
    
    // MARK: - Configuration
    private func configure() {
        configureConversationListView()
        configureOwnView()
    }
    
    private func configureConversationListView() {
        let conversationListView = ConversationListView(model: viewModel.conversationsModel) { [weak self] data in
            DispatchQueue.main.async {
                self?.router?.navigateToChatRoomWithIdentifier(data.chatRoomIdentifier, profileData: .id(data.memberData.id))
            }
        }
        
        embedView(conversationListView, to: self.view)
        
        self.conversationListView = conversationListView
    }
    
    private func configureOwnView() {
        title = "navigation.messages".localized()
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoViewModel()
    }
    
    private func sinkIntoViewModel() {
        bindToViewModel(viewModel, cancellables: &cancellables)
    }
}

// MARK: - Protocol conformance
// MARK: Navigable
extension PrivateChatListViewController: Navigable {
    static var storyboardScene: StoryboardScene {
        .community
    }
}

// MARK: Routable
extension PrivateChatListViewController: Routable {
    func assignRouter(_ router: PrivateChatListRouter) {
        self.router = router
    }
}
