//
//  InvitationCodeRouter.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 02/09/2022.
//

import Combine
import Foundation
import UIKit

enum InvitationCodeUpdateEvent {
    case codeAccepted
}

typealias InvitationCodeUpdateEventsSubject = PassthroughSubject<InvitationCodeUpdateEvent, Never>

protocol InvitationCodeRouterProtocol: Router {
    var invitationCodeUpdateEventsSubject: InvitationCodeUpdateEventsSubject { get }
}

final class InvitationCodeRouter: InvitationCodeRouterProtocol {
    // MARK: - Properties
    weak var navigationController: UINavigationController?
    let invitationCodeUpdateEventsSubject: InvitationCodeUpdateEventsSubject
    
    // MARK: - Initialization
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.invitationCodeUpdateEventsSubject = InvitationCodeUpdateEventsSubject()
    }
    
    init(navigationController: UINavigationController, eventsSubject: InvitationCodeUpdateEventsSubject) {
        self.navigationController = navigationController
        self.invitationCodeUpdateEventsSubject = eventsSubject
    }
    
    // MARK: - Public API
    func navigateAfterSuccess() {
        guard let navigationController else {
            fatalError("Missing \(UINavigationController.self) instance.")
        }
        
        navigationController.popViewController(animated: true)
    }
}
