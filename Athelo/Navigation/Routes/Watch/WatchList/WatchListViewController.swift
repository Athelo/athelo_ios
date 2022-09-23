//
//  WatchListViewController.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 05/07/2022.
//

import SwiftUI
import UIKit

final class WatchListViewController: BaseViewController {
    // MARK: - Outlets
    @IBOutlet private weak var viewContainer: UIView!
    
    // MARK: - Properties
    private let viewModel = WatchListViewModel()
    private var router: WatchListRouter?
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
    }
    
    // MARK: - Configure
    private func configure() {
        configureContainerView()
        configureOwnView()
    }
    
    private func configureContainerView() {
        let watchListView = WatchListView(model: viewModel.model, delegate: self)
        let hostingViewController = UIHostingController(rootView: watchListView)
        
        hostingViewController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingViewController.view.backgroundColor = .clear
        
        addChild(hostingViewController)
        viewContainer.addSubview(hostingViewController.view)
        
        hostingViewController.view.stretchToSuperview()
        
        hostingViewController.didMove(toParent: self)
    }
    
    private func configureOwnView() {
        navigationItem.displayAppLogo()
    }
}

// MARK: - Protocol conformance
// MARK: Navigable
extension WatchListViewController: Navigable {
    static var storyboardScene: StoryboardScene {
        .watch
    }
}

// MARK: Routable
extension WatchListViewController: Routable {
    func assignRouter(_ router: WatchListRouter) {
        self.router = router
    }
}

// MARK: WatchListViewDelegate
extension WatchListViewController: WatchListViewDelegate {
    func watchListViewSelectedDevice(_ deviceData: DeviceData) {
        if deviceData.type == .fitbit {
            router?.navigateToDeviceConnection(for: deviceData.type)
        } else {
            displayMessage("message.comingsoon".localized(), type: .plain)
        }
    }
}
