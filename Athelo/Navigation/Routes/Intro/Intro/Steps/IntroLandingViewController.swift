//
//  IntroLandingViewController.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 01/06/2022.
//

import UIKit

final class IntroLandingViewController: BaseViewController {
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
    }
    
    // MARK: - Configuration
    private func configure() {
        configureOwnView()
    }
    
    private func configureOwnView() {
        view.backgroundColor = .clear
    }
}

// MARK: - Protocol conformance
// MARK: Navigable
extension IntroLandingViewController: Navigable {
    static var storyboardScene: StoryboardScene {
        .intro
    }
}
