//
//  UIView+Loading.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 02/06/2022.
//

import Foundation
import UIKit

@MainActor extension UIWindow {
    // MARK: - Properties
    private var loadingViewTag: Int {
        Unmanaged.passUnretained(self).toOpaque().hashValue
    }
    
    private var loadingContainerView: UIView? {
        viewWithTag(loadingViewTag)
    }
    
    // MARK: - Public API
    func displayCustomView<T: UIView>(_ view: T, animated: Bool = true, pinningClosure: (_ pinnedView: UIView, _ superview: UIView) -> Void) {
        displayContainerView(animated: animated)
        guard let containerView = loadingContainerView,
              containerView.subviews.first(where: { $0 is T }) == nil else {
            return
        }
        
        view.alpha = 0.0
        view.translatesAutoresizingMaskIntoConstraints = false
        
        pinningClosure(view, containerView)
        
        guard view.superview == containerView else {
            return
        }
        
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0.0) {
                view.alpha = 1.0
            }
        } else {
            view.alpha = 1.0
        }
    }
    
    func displayLoadingView(animated: Bool = true) {
        displayContainerView(animated: true)
        guard let containerView = loadingContainerView,
              containerView.subviews.first(where: { $0 is LargeLoadingView }) == nil else {
            return
        }
        
        let loadingView = LargeLoadingView.instantiate()
        
        loadingView.alpha = 0.0
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        
        if let popupView = containerView.subviews.compactMap({ $0 as? PopupView }).first {
            containerView.insertSubview(loadingView, belowSubview: popupView)
        } else {
            containerView.addSubview(loadingView)
        }
        
        NSLayoutConstraint.activate([
            loadingView.centerXAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.centerYAnchor),
            loadingView.widthAnchor.constraint(lessThanOrEqualTo: containerView.widthAnchor, multiplier: 1.0, constant: -32)
        ])
        
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0.0, options: [.beginFromCurrentState]) {
                loadingView.alpha = 1.0
            }
        } else {
            loadingView.alpha = 1.0
        }
    }
    
    func displayPopupView(with configuration: PopupConfigurationData, animated: Bool = true) {
        displayContainerView(animated: true)
        guard let containerView = loadingContainerView,
              containerView.subviews.first(where: { $0 is PopupView }) == nil else {
            return
        }
        
        let popupView = PopupView.instantiate()
        
        popupView.assignOverlayContainer(self)
        popupView.configure(using: configuration)
        
        popupView.alpha = 0.0
        popupView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(popupView)
        
        NSLayoutConstraint.activate([
            popupView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            popupView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            popupView.topAnchor.constraint(greaterThanOrEqualTo: containerView.topAnchor, constant: 16.0),
            popupView.widthAnchor.constraint(equalTo: containerView.widthAnchor, constant: -32.0)
        ])
        
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0.0, options: [.beginFromCurrentState]) {
                popupView.alpha = 1.0
            }
        } else {
            popupView.alpha = 1.0
        }
    }
    
    func hideCustomView<T: UIView>(of targetClass: T.Type, animated: Bool = true) {
        guard LargeLoadingView.self != targetClass,
              PopupView.self != targetClass else {
            return
        }
        
        hideSubview(ofClass: targetClass, animated: animated)
    }
    
    func hideLoadingView(animated: Bool = true) {
        hideSubview(ofClass: LargeLoadingView.self, animated: animated)
    }
    
    func hidePopupView(animated: Bool = true) {
        hideSubview(ofClass: PopupView.self, animated: animated)
    }
    
    // MARK: - Updates
    private func displayContainerView(animated: Bool = true) {
        guard loadingContainerView == nil else {
            return
        }
        
        let loadingContainerView = UIView()
        
        loadingContainerView.backgroundColor = .withStyle(.black).withAlphaComponent(0.33)
        loadingContainerView.translatesAutoresizingMaskIntoConstraints = false
        loadingContainerView.tag = self.loadingViewTag
        loadingContainerView.alpha = 0.0
        
        addSubview(loadingContainerView)
        
        NSLayoutConstraint.activate([
            loadingContainerView.topAnchor.constraint(equalTo: topAnchor),
            loadingContainerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            loadingContainerView.leftAnchor.constraint(equalTo: leftAnchor),
            loadingContainerView.rightAnchor.constraint(equalTo: rightAnchor)
        ])
        
        if animated {
            loadingContainerView.layoutIfNeeded()

            UIView.animate(withDuration: 0.3, delay: 0.0, options: [.beginFromCurrentState]) {
                loadingContainerView.alpha = 1.0
            }
        } else {
            loadingContainerView.alpha = 0.0
        }
    }
    
    private func hideContainerView(animated: Bool = true) {
        guard let loadingContainerView = loadingContainerView else {
            return
        }
        
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0.0, options: [.beginFromCurrentState]) {
                loadingContainerView.alpha = 0.0
            } completion: { completed in
                if completed {
                    loadingContainerView.removeFromSuperview()
                }
            }
        } else {
            loadingContainerView.removeFromSuperview()
        }
    }
    
    private func hideSubview<T: UIView>(ofClass viewClass: T.Type, animated: Bool = true) {
        guard let containerView = loadingContainerView,
              let targetSubview = containerView.subviews.compactMap({ $0 as? T }).first else {
            return
        }
        
        if containerView.subviews.count > 1 {
            if animated {
                UIView.animate(withDuration: 0.3, delay: 0.0, options: [.beginFromCurrentState]) {
                    targetSubview.alpha = 0.0
                } completion: { [weak self] completed in
                    guard completed else {
                        return
                    }
                    
                    targetSubview.removeFromSuperview()
                    if self?.loadingContainerView?.subviews.isEmpty == true {
                        self?.hideContainerView()
                    }
                }
            } else {
                targetSubview.removeFromSuperview()
            }
        } else {
            hideContainerView(animated: animated)
        }
    }
}
