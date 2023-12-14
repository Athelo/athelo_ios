//
//  PrivateChatListRouter.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 21/09/2022.
//

import Foundation
import UIKit

final class PrivateChatListRouter: CommunityRouter {
    // MARK: - Public API
    func navigateToChatRoomWithIdentifier(_ chatRoomIdentifier: String?, profileData: CommunityChatViewController.ChatContactData) {
        guard let navigationController else {
            fatalError("Missing \(UINavigationController.self) instance.")
        }
        
        var dataType: CommunityChatViewController.ChatDataType?
        if let chatRoomIdentifier, !chatRoomIdentifier.isEmpty {
            dataType = .roomID(chatRoomIdentifier)
        }
        
        let router = CommunityChatRouter(navigationController: navigationController, communityUpdateEventSubject: communityUpdateEventsSubject)
        let viewController = CommunityChatViewController.viewController(configurationData: .init(dataType: dataType, identityData: profileData), router: router)
        
        navigationController.pushViewController(viewController, animated: true)
    }
}
