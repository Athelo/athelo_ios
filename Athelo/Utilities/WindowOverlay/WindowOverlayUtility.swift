//
//  WindowOverlayUtility.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 31/05/2022.
//

import Combine
import Foundation
import SwiftUI
import UIKit

@MainActor final class WindowOverlayUtility {
    // MARK: - Constants
//    private enum LayerPriority {
//        case messageView
//        case networkView
//        case popupContainer
//
//        var zPosition: CGFloat {
//            switch self {
//            case .messageView:
//                return 2.0
//            case .networkView:
//                return 3.0
//            case .popupContainer:
//                return 1.0
//            }
//        }
//    }
    
    // MARK: - Properties
    private let window: UIWindow
    
    // MARK: - Outlets
    private var messageView: InfoMessageView?
    private var noNetworkView: NoNetworkView?
    
    private var messageDismissalCancellable: AnyCancellable?
    
    // MARK: - Initialization
    init(window: UIWindow) {
        self.window = window
    }
    
    // MARK: - Public API
    func displayCustomOverlayView<T: UIView>(_ view: T, animated: Bool = true, pinningClosure: (_ pinnedView: UIView, _ superview: UIView) -> Void) {
        window.displayCustomView(view, animated: animated, pinningClosure: pinningClosure)
        
        bringMessagesToFront()
    }
    
    func displayCustomOverlayView<T: View>(_ view: T, animated: Bool = true, pinningClosure: (_ pinnedView: UIView, _ superview: UIView) -> Void) {
        window.displayCustomView(view, animated: animated, pinningClosure: pinningClosure)
        
        bringMessagesToFront()
    }
    
    func displayLoadingView(animated: Bool = true) {
        window.displayLoadingView(animated: animated)
        
        bringMessagesToFront()
    }
    
    func displayPopupView(with configuration: PopupConfigurationData, animated: Bool = true) {
        window.displayPopupView(with: configuration, animated: animated)
        
        bringMessagesToFront()
    }
    
    func displayNoNetworkView() {
        if noNetworkView == nil {
            let noNetworkView = NoNetworkView.instantiate()
            
            noNetworkView.alpha = 0.0
            
            window.addSubview(noNetworkView)
            window.bringSubviewToFront(noNetworkView)
            
            noNetworkView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                noNetworkView.topAnchor.constraint(equalTo: window.safeAreaLayoutGuide.topAnchor, constant: 8.0),
                noNetworkView.leadingAnchor.constraint(equalTo: window.safeAreaLayoutGuide.leadingAnchor, constant: 16.0),
                noNetworkView.trailingAnchor.constraint(equalTo: window.safeAreaLayoutGuide.trailingAnchor, constant: -16.0)
            ])
            
            self.noNetworkView = noNetworkView
        }
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: [.beginFromCurrentState]) { [weak self] in
            self?.noNetworkView?.alpha = 1.0
        }
    }
    
    func dismissMessage() {
        guard messageView != nil else {
            return
        }

        hideMessageView()
    }
    
    func displayMessage(_ message: String, type: InfoMessageData.MessageType) {
        var delay: TimeInterval = 0.0
        if messageView != nil {
            hideMessageView()
            delay = 0.3
        }
        
        let messageView = InfoMessageView.instantiate()
        
        messageView.alpha = 0.0
        messageView.displayMessage(message, type: type)
        
        window.addSubview(messageView)
        window.bringSubviewToFront(messageView)
        
        messageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            messageView.topAnchor.constraint(equalTo: window.safeAreaLayoutGuide.topAnchor, constant: 8.0),
            messageView.leadingAnchor.constraint(equalTo: window.safeAreaLayoutGuide.leadingAnchor, constant: 16.0),
            messageView.trailingAnchor.constraint(equalTo: window.safeAreaLayoutGuide.trailingAnchor, constant: -16.0)
        ])
        
        UIView.animate(withDuration: 0.3, delay: delay) {
            messageView.alpha = 1.0
        }
        
        self.messageView = messageView
        
        messageDismissalCancellable?.cancel()
        messageDismissalCancellable = messageView.dismissButtonTapPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.dismissMessage()
            }
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleMessageViewGestureRecognizer(_:)))
        messageView.addGestureRecognizer(panGestureRecognizer)
    }
    
    func hideCustomOverlayView<T: UIView>(of targetClass: T.Type, animated: Bool = true) {
        window.hideCustomView(of: targetClass, animated: animated)
    }
    
    func hideCustomOverlayView<Tag: RawRepresentable<Int>>(withPinningTag pinningTag: Tag, animated: Bool = true) {
        window.hideCustomView(withPinningTag: pinningTag, animated: animated)
    }
    
    func hideLoadingView(animated: Bool = true) {
        window.hideLoadingView(animated: animated)
    }
    
    func hideNoNetworkView() {
        guard noNetworkView != nil else {
            return
        }
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: [.beginFromCurrentState]) { [weak self] in
            self?.noNetworkView?.alpha = 0.0
        }
    }
    
    func hidePopupView(animated: Bool = true) {
        window.hidePopupView(animated: animated)
    }
    
    // MARK: - Updates
    private func bringMessagesToFront() {
        if let messageView = messageView, window.subviews.contains(messageView) {
            window.bringSubviewToFront(messageView)
        }
        
        if let noNetworkView = noNetworkView, window.subviews.contains(noNetworkView) {
            window.bringSubviewToFront(noNetworkView)
        }
    }
    
    private func changeParameters(for panGestureRecognizer: UIPanGestureRecognizer) -> (alpha: CGFloat, offset: CGFloat, progress: Double)? {
        guard let messageView = messageView,
              panGestureRecognizer.view === messageView, panGestureRecognizer.state == .changed else {
            return nil
        }
        
        let translation = panGestureRecognizer.translation(in: window)
        let progression = max(0.0, min(1.0, -translation.y / messageView.bounds.height))
        
        let offset = max(-messageView.bounds.height, messageView.bounds.height * -progression)
        let alpha = max(0.0, min(1.0, 1.0 - progression / 2.0))
        
        return (alpha, offset, Double(progression))
    }
    
    private func hideMessageView(instantly: Bool = false) {
        guard let messageView = messageView else {
            return
        }

        self.messageView = nil
        
        let animationTime = instantly ? 0.1 : 0.3
        UIView.animate(withDuration: animationTime, delay: 0.0, options: [.beginFromCurrentState]) {
            messageView.alpha = 0.0
            messageView.transform = .identity.translatedBy(x: 0.0, y: -messageView.bounds.height)
        } completion: { _ in
            messageView.removeFromSuperview()
        }
    }
    
    private func resetMessageView() {
        UIView.animate(withDuration: 0.3, delay: 0.0, options: [.beginFromCurrentState]) { [weak self] in
            self?.messageView?.transform = .identity
            self?.messageView?.alpha = 1.0
        }
    }
    
    // MARK: - Actions
    @objc private func handleMessageViewGestureRecognizer(_ panGestureRecognizer: UIPanGestureRecognizer) {
        guard panGestureRecognizer.view === messageView else {
            return
        }
        
        switch panGestureRecognizer.state {
        case .changed:
            if let parameters = changeParameters(for: panGestureRecognizer) {
                messageView?.transform = .identity.translatedBy(x: 0.0, y: parameters.offset)
                messageView?.alpha = parameters.alpha
            }
        case .ended:
            if panGestureRecognizer.velocity(in: window).y < -200.0 {
                hideMessageView(instantly: true)
            } else if let progress = changeParameters(for: panGestureRecognizer)?.progress {
                if progress > 0.5 {
                    hideMessageView()
                } else {
                    resetMessageView()
                }
            } else {
                resetMessageView()
            }
        case .cancelled:
            resetMessageView()
        default:
            break
        }
    }
}

