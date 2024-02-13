//
//  AppRouter.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 31/05/2022.
//

import Combine
import Foundation
import UIKit

@MainActor final class AppRouter {
    // MARK: - Constants
    enum Constants {
        static let rootTransitionTime: TimeInterval = 0.25
    }
    
    enum Root: Hashable {
        case accessCode
        case auth
        case home
        case intro
        case roleSelection
        case splash
        case sync
    }
    
    // MARK: - Properties
    private(set) var window: UIWindow
    
    private let networkMonitor: NetworkUtility
    let windowOverlayUtility: WindowOverlayUtility
    
    private var postponedNavigationRoute: NavigationRoute?
    private(set) var root: Root?
    var homeTab: MainContentViewController.Tab? {
        (window.rootViewController as? MainContentViewController)?.selectedTab
    }
    
    /// Global instance of coordinator bound to active application scene.
    static var current: AppRouter {
        // Since app works in single window mode, it's safe to assume that only one scene will be available at any given time.
        
        guard let router = (Array(UIApplication.shared.connectedScenes).first?.delegate as? SceneDelegate)?.router else {
            fatalError("Cannot reach main app router.")
        }

        return router
    }
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - Initialization
    init(window: UIWindow) {
        self.window = window
        
        self.networkMonitor = NetworkUtility.utility
        self.windowOverlayUtility = WindowOverlayUtility(window: window)
        
        sink()
    }
    
    // MARK: - Public API
    func appendMenuNavigationItem(to viewController: UIViewController) {
        guard root == .home,
              let contentViewController = window.rootViewController as? MainContentViewController else {
            return
        }
        
        contentViewController.appendMenuNavigationItem(to: viewController)
    }
    
    /// Exchanges root navigation route visible on active screen.
    ///
    /// - Parameter root: Root type to be displayed.
    func exchangeRoot(_ root: Root) {
        guard markRoot(root) else {
            return
        }
        
        // Forcing so that no popup artifacts are being held/displayed.
        windowOverlayUtility.hidePopupView()
        
        switch root {
        case .accessCode:
            displayAccessCodeRoot()
        case .auth:
            displayAuthRoot()
        case .home:
            displayHome()
        case .intro:
            displayIntroRoot()
        case .roleSelection:
            displayRoleSelection()
        case .splash:
            displaySplashRoot()
        case .sync:
            displaySyncRoot()
        }
    }
    
    /// Marks router as if root was set to given value.
    ///
    /// This method should be used only in case manual transition to root view has been performed.
    ///
    /// - Parameter root: Root type to mark as active.
    ///
    /// - Returns: Result of marking operation. Operation fails if root has been already set to desired value.
    @discardableResult func markRoot(_ root: Root) -> Bool {
        guard self.root != root else {
            return false
        }
        
        self.root = root
        
        return true
    }
    
    func navigate(using notificationRoute: NotificationRoute) {
        switch notificationRoute {
        case .resolved(let route):
            navigate(using: route)
        case .loginRequired(let route):
            postponedNavigationRoute = route
        case .none:
            break
        }
    }
    
    func navigate(using navigationRoute: NavigationRoute) {
        guard IdentityUtility.userData != nil,
              root == .home,
              let contentViewController = window.rootViewController as? MainContentViewController else {
            return
        }
        
        contentViewController.navigate(using: navigationRoute)
    }

    func switchHomeTab(_ tab: MainContentViewController.Tab) {
        guard root == .home,
              let contentViewController = window.rootViewController as? MainContentViewController else {
            return
        }
        
        contentViewController.switchTab(to: tab)
    }
    
    // MARK: - Navigation
    private func displayAccessCodeRoot() {
        let router = AccessCodeRouter()
        let viewController = AccessCodeViewController.viewController(router: router)
        
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        
        UIView.transition(with: window, duration: Constants.rootTransitionTime, options: [.transitionCrossDissolve], animations: nil)
    }
    
    private func displayAuthRoot() {
        let router = AuthenticationRouter(updateEventsSubject: nil)
        let viewController = AuthenticationViewController.viewController(router: router)
        
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        
        UIView.transition(with: window, duration: Constants.rootTransitionTime, options: [.transitionCrossDissolve], animations: nil)
    }
    
    private func displayHome() {
        let contentViewController = MainContentViewController()
        
        window.rootViewController = contentViewController
        window.makeKeyAndVisible()
        
        if let postponedNavigationRoute = postponedNavigationRoute {
            contentViewController.navigate(using: postponedNavigationRoute)
            self.postponedNavigationRoute = nil
        }
        
        UIView.transition(with: window, duration: Constants.rootTransitionTime, options: [.transitionCrossDissolve], animations: nil)
    }
    
    private func displayIntroRoot() {
        let navigationController = BaseNavigationController()
        
        navigationController.navigationBar.isHidden = true
        
        let router = IntroRouter(navigationController: navigationController)
        let viewController = IntroViewController.viewController(router: router)
        
        navigationController.setViewControllers([viewController], animated: false)
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        UIView.transition(with: window, duration: Constants.rootTransitionTime, options: [.transitionCrossDissolve], animations: nil)
    }
    
    private func displayRoleSelection() {
        let navigationController = BaseNavigationController()
        
        let configurationData = SelectRoleViewController.ConfigurationData(expectsDeviceSync: true)
        let router = SelectRoleRouter(navigationController: navigationController)
        let viewController = SelectRoleViewController.viewController(configurationData: configurationData, router: router)
        
        navigationController.setViewControllers([viewController], animated: false)
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        UIView.transition(with: window, duration: Constants.rootTransitionTime, options: [.transitionCrossDissolve], animations: nil)
    }
    
    private func displaySplashRoot() {
        let router = SplashRouter()
        let viewController = SplashViewController.viewController(router: router)
        
        window.rootViewController = viewController
        window.makeKeyAndVisible()
    }
    
    private func displaySyncRoot() {
        let navigationController = BaseNavigationController()
        
        navigationController.makeNavigationBarTranslucent()
        
        let router = ConnectDeviceRouter(navigationController: navigationController)
        let configurationData = ConnectDeviceViewController.ConfigurationData(deviceType: .fitbit) {
            AppRouter.current.exchangeRoot(.home)
        }
        
        let viewController = ConnectDeviceViewController.viewController(configurationData: configurationData, router: router)
        
        navigationController.setViewControllers([viewController], animated: false)
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        UIView.transition(with: window, duration: Constants.rootTransitionTime, options: [.transitionCrossDissolve], animations: nil)
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoNetworkUtility()
    }
    
    private func sinkIntoNetworkUtility() {
        networkMonitor.networkAvailablePublisher
            .debounce(for: 0.2, scheduler: DispatchQueue.main)
            .sink { [weak overlayUtility = windowOverlayUtility] in
                if $0 {
                    overlayUtility?.hideNoNetworkView()
                } else {
                    overlayUtility?.displayNoNetworkView()
                }
            }.store(in: &cancellables)
    }
}

// MARK: - Protocol conformance
// MARK: IdentitySignInWithGoogleUIProvider
extension AppRouter: IdentitySignInWithGoogleUIProvider {
    var signInWithGooglePresentingViewController: UIViewController {
        guard let rootViewController = window.rootViewController else {
            fatalError("Cannot provide view controller for presenting Google Sign In UI.")
        }
        
        return rootViewController
    }
}
