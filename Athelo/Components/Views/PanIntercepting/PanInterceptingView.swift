//
//  PanInterceptingView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 19/08/2022.
//

import Combine
import UIKit

class PanInterceptingView: UIView {
    // MARK: - Properties
    private var timerCancellable: AnyCancellable?
    
    private weak var navigationController: UINavigationController?
    
    // MARK: - Public API
    func assignInterceptedNavigationController(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        
        assignGestureRecognizers()
    }

    // MARK: - Updates
    private func assignGestureRecognizers() {
        guard !(gestureRecognizers?.isEmpty == false) else {
            return
        }
        
        weak var weakSelf = self
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: weakSelf, action: #selector(handlePanGesture(_:)))
        let screenEdgeGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: weakSelf, action: #selector(handlePanGesture(_:)))
        
        panGestureRecognizer.delegate = self
        screenEdgeGestureRecognizer.delegate = self
        
        addGestureRecognizer(panGestureRecognizer)
        addGestureRecognizer(screenEdgeGestureRecognizer)
    }
    
    // MARK: Actions
    @objc private func handlePanGesture(_ sender: Any) {
        /* ... */
    }
}

// MARK: - Protocol conformance
// MARK: UIGestureRecognizerDelegate
extension PanInterceptingView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let navigationController = navigationController else {
            return false
        }
        
        navigationController.interactivePopGestureRecognizer?.isEnabled = false
        
        timerCancellable?.cancel()
        timerCancellable = Timer.publish(every: 0.2, on: .main, in: .default)
            .autoconnect()
            .first()
            .sinkDiscardingValue { [weak self] in
                self?.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
            }
        
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}
