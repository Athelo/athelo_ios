//
//  GroupChatLandingViewController.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 24/06/2022.
//

import Combine
import UIKit

final class CommunitiesLandingViewController: BaseViewController {
    // MARK: - Outlets
    @IBOutlet private weak var viewGradientContainer: UIView!
    
    // MARK: - Properties
    private var router: CommunitiesLandingRouter?
    
    private var cancellables: [AnyCancellable] = []

    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }
    
    // MARK: - Configuration
    private func configure() {
        configureGradientContainerView()
        configureOwnView()
    }
    
    private func configureGradientContainerView() {
        var imageData: BottomClippedGradientView.ImageData?
        if let backgroundImage = UIImage(named: "womanYogaPose") {
            imageData = .init(image: backgroundImage, shouldClip: false, yOffset: -16.0)
        }
        
        displayBackgroundGradient(in: viewGradientContainer, imageData: imageData)
    }
    
    private func configureOwnView() {
        navigationItem.displayAppLogo()
        
        cancellables.append(navigationItem.displayUserAvatar(with: router))
    }
    
    // MARK: - Actions
    @IBAction private func letsStartButtonTapped(_ sender: Any) {
        PreferencesStore.setCommunitiesLandingAsDisplayed(true)
        
        router?.navigateToCommunitiesList()
    }
}

// MARK: - Protocol conformance
// MARK: Navigable
extension CommunitiesLandingViewController: Navigable {
    static var storyboardScene: StoryboardScene {
        .community
    }
}

// MARK: Routable
extension CommunitiesLandingViewController: Routable {
    typealias RouterType = CommunitiesLandingRouter
    
    func assignRouter(_ router: CommunitiesLandingRouter) {
        self.router = router
    }
}
