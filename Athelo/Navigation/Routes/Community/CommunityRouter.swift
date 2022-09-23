//
//  CommunityRouter.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 13/07/2022.
//

import Combine
import Foundation
import UIKit

class CommunityRouter: Router {
    // MARK: - Properties
    weak var navigationController: UINavigationController?
    let communityUpdateEventsSubject: CommunityUpdateEventsSubject
    
    // MARK: - Initialization
    required init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.communityUpdateEventsSubject = CommunityUpdateEventsSubject()
    }
    
    init(navigationController: UINavigationController, communityUpdateEventSubject: CommunityUpdateEventsSubject?) {
        self.navigationController = navigationController
        self.communityUpdateEventsSubject = communityUpdateEventSubject ?? CommunityUpdateEventsSubject()
    }
}

// MARK: - Helper extensions
extension CommunityRouter {
    typealias CommunityUpdateEventsSubject = PassthroughSubject<UpdateEvent, Never>
    
    enum UpdateEvent {
        case chatRoomUpdated(ChatRoomData)
        
        var updatedChatRoomData: ChatRoomData? {
            switch self {
            case .chatRoomUpdated(let data):
                return data
            }
        }
    }
}
