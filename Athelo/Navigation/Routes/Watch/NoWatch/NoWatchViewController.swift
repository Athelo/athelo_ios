//
//  NoWatchViewController.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 28/06/2022.
//

import Combine
import UIKit

final class NoWatchViewController: BaseViewController {
    // MARK: - Outlets
    @IBOutlet private weak var viewGradientContainer: UIView!
    
    // MARK: - Properties
    private var router: NoWatchRouter?
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
    }
    
    // MARK: - Configuration
    private func configure() {
        configureGradientContainerView()
    }
    
    private func configureGradientContainerView() {
        var imageData: BottomClippedGradientViewImageData?
        if let image = UIImage(named: "womanPhone") {
            imageData = .init(image: image, shouldClip: true, yOffset: 0.0)
        }
        
        displayBackgroundGradient(in: viewGradientContainer, imageData: imageData)
    }
    
    // MARK: - Actions
    @IBAction private func connectSmartWatchButtonTapped(_ sender: Any) {
        router?.navigateToDeviceConnection(for: .fitbit)
    }
}

// MARK: - Protocol conformance
// MARK: Navigable
extension NoWatchViewController: Navigable {
    static var storyboardScene: StoryboardScene {
        .watch
    }
}

// MARK: - Routable
extension NoWatchViewController: Routable {
    func assignRouter(_ router: NoWatchRouter) {
        self.router = router
    }
}
