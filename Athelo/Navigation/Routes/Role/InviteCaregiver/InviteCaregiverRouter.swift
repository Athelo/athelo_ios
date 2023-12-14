//
//  InviteCaregiverRouter.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 23/03/2023.
//

import Combine
import Foundation
import UIKit

enum InviteCaregiverUpdateEvent {
    case invitationSent
}

typealias InviteCaregiverUpdateEventsSubject = PassthroughSubject<InviteCaregiverUpdateEvent, Never>

protocol InviteCaregiverRouterProtocol: Router {
    var inviteCaregiverUpdateEventsSubject: InviteCaregiverUpdateEventsSubject { get }
}

final class InviteCaregiverRouter: InviteCaregiverRouterProtocol {
    // MARK: - Properties
    weak var navigationController: UINavigationController?
    let inviteCaregiverUpdateEventsSubject: InviteCaregiverUpdateEventsSubject
    
    // MARK: - Initialization
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.inviteCaregiverUpdateEventsSubject = InviteCaregiverUpdateEventsSubject()
    }
    
    init(navigationController: UINavigationController, eventsSubject: InviteCaregiverUpdateEventsSubject) {
        self.navigationController = navigationController
        self.inviteCaregiverUpdateEventsSubject = eventsSubject
    }
    
    // MARK: - Public API
    func navigateAfterSuccess() {
        guard let navigationController else {
            fatalError("Missing \(UINavigationController.self) instance.")
        }
        
        navigationController.popViewController(animated: true)
    }
}
