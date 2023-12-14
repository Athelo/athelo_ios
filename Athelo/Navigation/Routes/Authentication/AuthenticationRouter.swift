//
//  AuthenticationRouter.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 02/06/2022.
//

import Combine
import UIKit

struct AuthenticationPingError: Error {
    /* ... */
}

enum AuthenticationUpdateEvent {
    case legalLabelVisibilityChanged(Bool)
    case modelStateChanged(ViewModelState)
    
    var legalVisibility: Bool? {
        switch self {
        case .legalLabelVisibilityChanged(let isVisible):
            return isVisible
        case .modelStateChanged:
            return nil
        }
    }
    
    var modelState: ViewModelState? {
        switch self {
        case .modelStateChanged(let state):
            return state
        case .legalLabelVisibilityChanged:
            return nil
        }
    }
}

protocol AuthenticationRouterProtocol {
    typealias AuthenticationUpdateEventsSubject = PassthroughSubject<AuthenticationUpdateEvent, Never>
    
    var authenticationUpdateEventsSubject: AuthenticationUpdateEventsSubject { get }
}

class AuthenticationRouter: RouterProtocol, AuthenticationRouterProtocol {
    // MARK: - Properties
    let authenticationUpdateEventsSubject: AuthenticationUpdateEventsSubject
    
    // MARK: - Initialization
    init(updateEventsSubject: AuthenticationUpdateEventsSubject?) {
        authenticationUpdateEventsSubject = updateEventsSubject ?? AuthenticationUpdateEventsSubject()
    }
}

class AuthenticationNavigationRouter: Router, AuthenticationRouterProtocol {
    // MARK: - Properties
    weak var navigationController: UINavigationController?
    let authenticationUpdateEventsSubject: AuthenticationUpdateEventsSubject
    
    // MARK: - Initilization
    required init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.authenticationUpdateEventsSubject = AuthenticationUpdateEventsSubject()
    }
    
    init(navigationController: UINavigationController, updateEventsSubject: AuthenticationUpdateEventsSubject?) {
        self.navigationController = navigationController
        self.authenticationUpdateEventsSubject = updateEventsSubject ?? AuthenticationUpdateEventsSubject()
    }
    
    @MainActor func navigateOnSuccessfulAuthentication() {
        if IdentityUtility.activeUserRole != nil {
            AppRouter.current.exchangeRoot(.home)
        } else {
            AppRouter.current.exchangeRoot(.roleSelection)
        }
    }
}
