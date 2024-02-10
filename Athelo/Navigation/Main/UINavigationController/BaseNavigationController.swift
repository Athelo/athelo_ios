//
//  BaseNavigationController.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 31/05/2022.
//

import Combine
import UIKit

class BaseNavigationController: UINavigationController {
    // MARK: - Initialization
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        
        configure()
    }
    
    override init(navigationBarClass: AnyClass?, toolbarClass: AnyClass?) {
        super.init(navigationBarClass: navigationBarClass, toolbarClass: toolbarClass)
        
        configure()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        configure()
    }
    
    // MARK: - Configuration
    private func configure() {
        configureOwnView()
    }
    
    private func configureOwnView() {
        updateBackButtonStyle()
        updateNavigationBarStyle()
        
        delegate = self
    }
    
    // MARK: - Updates
    override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        for viewController in viewControllers {
            viewController.updateBackButtonAppearance()
        }
        
        super.setViewControllers(viewControllers, animated: true)
    }
    
    private func updateBackButtonStyle() {
        let image = UIImage(named: "back")
        
        navigationBar.backIndicatorImage = image
        navigationBar.backIndicatorTransitionMaskImage = image
        
    }
    
    private func updateNavigationBarStyle() {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.withStyle(.headline20),
            .foregroundColor: UIColor.withStyle(.gray)
        ]
        
        navigationBar.titleTextAttributes = attributes
    }
}

// MARK: - Protocol conformance
// MARK: UINavigationControllerDelegate
extension BaseNavigationController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        AppRouter.current.windowOverlayUtility.dismissMessage()
        
        viewController.updateBackButtonAppearance()
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        viewController.updateBackButtonAppearance()
    }
}

// MARK: Helper extensions
private extension UIViewController {
    func updateBackButtonAppearance() {
        if navigationItem.backBarButtonItem == nil {
            navigationItem.backBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)
        }
    }
}
