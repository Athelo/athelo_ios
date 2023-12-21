//
//  MainContentViewController.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 09/06/2022.
//

import Combine
import UIKit

final class MainContentViewController: BaseViewController {
    // MARK: - Constants
    enum Tab: Int {
        case home
//        case sleep
//        case activity
        case community
        case news
    }
    
    // MARK: - Outlets
    private weak var contentController: BaseTabBarController?
    private weak var menuController: MenuViewController?
    
    // MARK: - Properties
    var selectedTab: Tab? {
        guard let selectedIndex = contentController?.selectedIndex else {
            return nil
        }
        
        return Tab(rawValue: selectedIndex)
    }
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        sink()
    }
    
    // MARK: - Public API
    func appendMenuNavigationItem(to viewController: UIViewController) {
        weak var weakSelf = self
        let barButtonItem = UIBarButtonItem(image: UIImage(named: "menu"), style: .plain, target: weakSelf, action: #selector(menuButtonTapped(_:)))
        
        viewController.navigationItem.leftBarButtonItem = barButtonItem
    }
    
    func switchTab(to tab: Tab) {
        guard tab.rawValue != contentController?.selectedIndex else {
            return
        }
        
        contentController?.selectedIndex = tab.rawValue
    }
    
    // MARK: - Configuration
    private func configure() {
        configureContentController()
        configureMenuController()
    }
    
    private func configureContentController() {
        func prepareRootController(_ viewController: UIViewController) {
            appendMenuNavigationItem(to: viewController)
        }
        
        func navigationController(for tab: Tab) -> UINavigationController {
            let navigationController = BaseNavigationController()
            
            navigationController.makeNavigationBarTranslucent()
            navigationController.tabBarItem = UITabBarItem(title: tab.tabBarItemTitle, image: tab.tabBarImage, tag: tab.rawValue)
            navigationController.tabBarItem.selectedImage = tab.tabBarSelectedImage
            navigationController.edgesForExtendedLayout = [.top, .left, .right]
            
            let titleFontAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.withStyle(.subtitle)
            ]
            
            navigationController.tabBarItem.setTitleTextAttributes(titleFontAttributes, for: .normal)
            navigationController.tabBarItem.setTitleTextAttributes(titleFontAttributes, for: .selected)
            
            return navigationController
        }
        
        guard contentController == nil else {
            return
        }
        
        let homeNavigationController = navigationController(for: .home)
        
        let router = HomeRouter(navigationController: homeNavigationController)
        let homeViewController = HomeViewController.viewController(router: router)
        prepareRootController(homeViewController)
        
        homeNavigationController.viewControllers = [homeViewController]
        
//        let sleepNavigationController = navigationController(for: .sleep)
//        
//        let sleepRouter = SleepRouter(navigationController: sleepNavigationController)
//        let sleepViewController = SleepViewController.viewController(router: sleepRouter)
//        prepareRootController(sleepViewController)
//        
//        sleepNavigationController.viewControllers = [sleepViewController]
        
//        let activityNavigationController = navigationController(for: .activity)
        
//        let activityRouter = ActvityRouter(navigationController: activityNavigationController)
//        let activityViewController = ActivityViewController.viewController(router: activityRouter)
//        prepareRootController(activityViewController)
//        
//        activityNavigationController.viewControllers = [activityViewController]
        
        let communityNavigationController = navigationController(for: .community)
        
        if PreferencesStore.hasDisplayedCommunitiesLanding() {
            let communityRouter = CommunitiesListRouter(navigationController: communityNavigationController)
            let communityViewController = CommunitiesListViewController.viewController(router: communityRouter)
            prepareRootController(communityViewController)
            
            communityNavigationController.viewControllers = [communityViewController]
        } else {
            let communityRouter = CommunitiesLandingRouter(navigationController: communityNavigationController)
            let communityViewController = CommunitiesLandingViewController.viewController(router: communityRouter)
            prepareRootController(communityViewController)
            
            communityNavigationController.viewControllers = [communityViewController]
        }
        
        let newsNavigationController = navigationController(for: .news)
        
        let newsRouter = NewsListRouter(navigationController: newsNavigationController)
        let newsViewController = NewsListViewController.viewController(router: newsRouter)
        prepareRootController(newsViewController)
        
        newsNavigationController.viewControllers = [newsViewController]
        
        let controller = BaseTabBarController()
        
        controller.viewControllers = [
            homeNavigationController,
//            sleepNavigationController,
//            activityNavigationController,
            communityNavigationController,
            newsNavigationController
        ]
        
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        
        addChild(controller)
        view.addSubview(controller.view)
        
        NSLayoutConstraint.activate([
            controller.view.topAnchor.constraint(equalTo: view.topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            controller.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            controller.view.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        
        controller.didMove(toParent: self)
        
        self.contentController = controller
    }
    
    private func configureMenuController() {
        guard menuController == nil else {
            return
        }
        
        let viewController = MenuViewController.viewController()
        
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        addChild(viewController)
        view.addSubview(viewController.view)
        
        NSLayoutConstraint.activate([
            viewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            viewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            viewController.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            viewController.view.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        
        viewController.didMove(toParent: self)
        
        viewController.hide(animated: false)
        
        self.menuController = viewController
    }
    
    func navigate(using navigationRoute: NavigationRoute) {
        switch navigationRoute {
        case .chatRoom(let chatRoomIdentifier):
            guard let navigationController = contentController?.viewControllers?[safe: Tab.community.rawValue] as? UINavigationController else {
                return
            }
            
            contentController?.selectedIndex = Tab.community.rawValue
            
            if !PreferencesStore.hasDisplayedCommunitiesLanding() {
                PreferencesStore.setCommunitiesLandingAsDisplayed(true)
                
                let communityRouter = CommunitiesLandingRouter(navigationController: navigationController)
                let communityViewController = CommunitiesLandingViewController.viewController(router: communityRouter)
                appendMenuNavigationItem(to: communityViewController)
                
                navigationController.viewControllers = [communityViewController]
                
                return
            }
            
            if let viewController = navigationController.viewControllers.last(where: { ($0 as? CommunityChatViewController)?.chatRoomidentifier == chatRoomIdentifier }) {
                navigationController.popToViewController(viewController, animated: true)
                
                ChatUtility.sendMessage(.getHistory(timestamp: Date().toChatTimestamp, limit: 100), chatRoomIdentifier: chatRoomIdentifier)
            } else {
                let router = CommunityChatRouter(navigationController: navigationController)
                let viewController = CommunityChatViewController.viewController(
                    configurationData: .init(
                        dataType: .roomID(chatRoomIdentifier),
                        identityData: nil
                    ),
                    router: router
                )
                
                // Manual assignment of view controller title is done here to prevent any future updates of `title` from not showing up. It just sometimes doesn't appear with no apparent (or at least reproducible) reason without assigning any non-empty value first when pushed from here. "Chat Room" seems neutral enough.
                viewController.title = "Chat Room"
                
                navigationController.pushViewController(viewController, animated: true)
            }
        }
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoMenuController()
    }
    
    private func sinkIntoMenuController() {
        menuController?.selectedOptionPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.menuController?.hide()
                self?.navigateToMenuOption($0)
            }.store(in: &cancellables)
    }
    
    // MARK: - Actions
    @IBAction private func menuButtonTapped(_ sender: Any?) {
        menuController?.reveal()
    }
    
    private func navigateToMenuOption(_ menuOption: MenuOption) {
        guard let navigationController = contentController?.selectedViewController as? UINavigationController,
              let displayedViewController = menuOption.viewController(for: navigationController) else {
            return
        }
        
        navigationController.pushViewController(displayedViewController, animated: true)
    }
}

// MARK: - Helper extensions
private extension MainContentViewController.Tab {
    private var tabBarItemTitleSuffix: String {
        switch self {
//        case .activity:
//            return "activity"
        case .community:
            return "community"
        case .home:
            return "home"
        case .news:
            return "news"
//        case .sleep:
//            return "sleep"
        }
    }
    
    var tabBarItemTitle: String {
        "navigation.tab.\(tabBarItemTitleSuffix)".localized()
    }
    
    var tabBarImage: UIImage? {
        switch self {
//        case .activity:
//            return UIImage(named: "lovedOne")
        case .community:
            return UIImage(named: "chat")
        case .home:
            return UIImage(named: "home")
        case .news:
            return UIImage(named: "book")
//        case .sleep:
//            return UIImage(named: "moon")
        }
    }
    
    var tabBarSelectedImage: UIImage? {
        switch self {
//        case .activity:
//            return UIImage(named: "lovedOneSolid")
        case .community:
            return UIImage(named: "chatSolid")
        case .home:
            return UIImage(named: "homeSolid")
        case .news:
            return UIImage(named: "bookSolid")
//        case .sleep:
//            return UIImage(named: "moonSolid")
        }
    }
}
