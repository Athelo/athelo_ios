//
//  CommunitiesListRouter.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 30/06/2022.
//

import Foundation
import UIKit

final class CommunitiesListRouter: CommunityRouter, UserProfileRoutable {    
    // MARK: - Public API
    func navigateToCommunityChat(_ chat: ChatRoomData) {
        guard let navigationController = navigationController else {
            fatalError("Missing \(UINavigationController.self) instance.")
        }
        
        let router = CommunityChatRouter(navigationController: navigationController, communityUpdateEventSubject: communityUpdateEventsSubject)
        let viewController = CommunityChatViewController.viewController(configurationData: .data(chat), router: router)
        
        navigationController.pushViewController(viewController, animated: true)
    }
}
