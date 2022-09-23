//
//  IntroRouter.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 01/06/2022.
//

import Foundation
import UIKit

final class IntroRouter: NSObject, Router {
    // MARK: - Properties
    var navigationController: UINavigationController?
    var interactionController: UIPercentDrivenInteractiveTransition?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    // MARK: - Public API
    func navigateToAuth() {
        Task {
            await AppRouter.current.exchangeRoot(.auth)
        }
    }
    
    func registerGestureRecognizerForTransition(_ panGestureRecognizer: UIPanGestureRecognizer) {
        panGestureRecognizer.addTarget(self, action: #selector(handleTransitionPanGestureRecognizer(_:)))
        
        navigationController?.delegate = self
    }
    
    // MARK: - Updates
    @objc private func handleTransitionPanGestureRecognizer(_ panGestureRecognizer: UIPanGestureRecognizer) {
        guard let view = navigationController?.view else {
            return
        }
        
        switch panGestureRecognizer.state {
        case .began:
            interactionController = UIPercentDrivenInteractiveTransition()
            
            let router = AuthenticationRouter(updateEventsSubject: nil)
            let viewController = AuthenticationViewController.viewController(router: router)
            
            navigationController?.pushViewController(viewController, animated: true)
        case .changed:
            guard let interactionController = interactionController else {
                break
            }
            
            let translation = panGestureRecognizer.translation(in: view)
            let progression = -translation.x / view.bounds.width
            
            interactionController.update(progression)
        case .ended:
            guard let interactionController = interactionController else {
                break
            }
            
            if panGestureRecognizer.velocity(in: view).x < -200.0 {
                interactionController.finish()
            } else {
                if interactionController.percentComplete >= 0.5 {
                    interactionController.finish()
                } else {
                    interactionController.cancel()
                }
            }
            
            self.interactionController = nil
        case .cancelled:
            interactionController?.cancel()
            interactionController = nil
        default:
            break
        }
    }
}

// MARK: - Protocol conformance
// MARK: UINavigationControllerDelegate
extension IntroRouter: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard operation == .push else {
            return nil
        }
        
        return self
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        self.interactionController
    }
}

// MARK: UIViewControllerAnimatedTransitioning
extension IntroRouter: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        1.0
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let targetViewController = transitionContext.viewController(forKey: .to),
              let sourceViewController = transitionContext.viewController(forKey: .from) else {
            fatalError("Missing view controllers for performing transition.")
        }
        
        transitionContext.containerView.backgroundColor = .withStyle(.background)
        
        targetViewController.view.alpha = 0.0
        targetViewController.view.transform = .init(scaleX: 0.7, y: 0.7)

        transitionContext.containerView.addSubview(targetViewController.view)
        targetViewController.view.backgroundColor = .clear
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext)) {
            sourceViewController.view.alpha = 0.5
            sourceViewController.view.center.x = -(transitionContext.containerView.bounds.width / 1.0)
            
            targetViewController.view.alpha = 1.0
            targetViewController.view.transform = .identity
        } completion: { _ in
            if !transitionContext.transitionWasCancelled {
                targetViewController.view.backgroundColor = .withStyle(.background)
                _ = AppRouter.current.markRoot(.auth)
            }
            
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
