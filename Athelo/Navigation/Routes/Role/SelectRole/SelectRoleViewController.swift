//
//  SelectRoleViewController.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 20/03/2023.
//

import UIKit

final class SelectRoleViewController: BaseViewController {
    // MARK: - Outlets
    private var selectRoleScreen: SelectRoleScreen?
    
    // MARK: - Properties
    private var router: SelectRoleRouter?
    
    private var configurationData: ConfigurationData?
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
    }
    
    // MARK: - Configuration
    private func configure() {
        configureContentView()
        configureOwnView()
    }
    
    private func configureContentView() {
        if selectRoleScreen != nil {
            return
        }
        
        let screen = SelectRoleScreen { [weak self] role in
            self?.router?.navigateToRoleDetails(using: role)
        }
        
        embedView(screen, to: view)
        
        self.selectRoleScreen = screen
    }
    
    private func configureOwnView() {
        navigationItem.displayAppLogo()
    }
}

// MARK: - Protocol conformance
// MARK: Configurable
extension SelectRoleViewController: Configurable {
    struct ConfigurationData {
        let expectsDeviceSync: Bool
    }
    
    func assignConfigurationData(_ configurationData: ConfigurationData) {
        self.configurationData = configurationData
    }
}

// MARK: Navigable
extension SelectRoleViewController: Navigable {
    static var storyboardScene: StoryboardScene {
        .role
    }
}

// MARK: Routable
extension SelectRoleViewController: Routable {
    func assignRouter(_ router: SelectRoleRouter) {
        self.router = router
    }
}
