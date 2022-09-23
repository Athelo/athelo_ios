//
//  KeyboardListeningViewController.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 01/06/2022.
//

import Combine
import UIKit

class KeyboardListeningViewController: BaseViewController {
    // MARK: - Constants
    private enum Constants {
        static let defaultOffsetUpdateAnimationTime: TimeInterval = 0.2
    }
    
    // MARK: - Properties
    private let keyboardInfoSubject = PassthroughSubject<KeyboardChangeData, Never>()
    var keyboardInfoPublisher: AnyPublisher<KeyboardChangeData, Never> {
        keyboardInfoSubject.eraseToAnyPublisher()
    }
    
    private var keyboardCancellables: [AnyCancellable] = []
    
    // MARK: - View lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        sinkIntoKeyboardChanges()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        view.endEditing(true)
        keyboardCancellables.cancelAndClear()
    }
    
    // MARK: - Public API
    func adjustBottomOffset(using constraint: NSLayoutConstraint, keyboardChangeData: KeyboardChangeData, additionalOffset: CGFloat? = nil, onOffsetDifference: ((CGFloat, UIView.AnimationCurve?, TimeInterval?) -> Void)? = nil) {
        if !Thread.isMainThread {
            DispatchQueue.main.async { [weak self] in
                self?.adjustBottomOffset(using: constraint, keyboardChangeData: keyboardChangeData)
            }
            return
        }
        
        let viewOnScreenFrame = view.convert(view.frame, to: nil)
        let viewScreenOffset = UIScreen.main.bounds.height - viewOnScreenFrame.maxY

        var targetOffset = max(0.0, keyboardChangeData.offsetFromScreenBottom - viewScreenOffset)
        if targetOffset > 0.0,
           let additionalOffset = additionalOffset, additionalOffset > 0.0 {
            targetOffset += additionalOffset
        }

        let offsetDifference = targetOffset - constraint.constant
        
        if let animationCurve = keyboardChangeData.keyboardInfo.animationCurve,
           let animationTime = keyboardChangeData.keyboardInfo.animationTime {
            onOffsetDifference?(offsetDifference, animationCurve, animationTime)
            
            let animator = UIViewPropertyAnimator(duration: animationTime, curve: animationCurve) { [weak self] in
                constraint.constant = targetOffset
                self?.view.layoutIfNeeded()
            }
            animator.startAnimation()
        } else {
            onOffsetDifference?(offsetDifference, nil, nil)
            
            UIView.animate(withDuration: Constants.defaultOffsetUpdateAnimationTime) { [weak self] in
                constraint.constant = targetOffset
                self?.view.layoutIfNeeded()
            }
        }
    }
    
    // MARK: - Sinks
    private func sinkIntoKeyboardChanges() {
        NotificationCenter.default.publisher(for: UIApplication.keyboardWillChangeFrameNotification)
            .compactMap({ $0.userInfo })
            .compactMap({ KeyboardInfo(userInfo: $0) })
            .map({ KeyboardChangeData(keyboardInfo: $0, offsetFromScreenBottom: $0.rect.height) })
            .sink { [weak self] in
                self?.keyboardInfoSubject.send($0)
            }.store(in: &keyboardCancellables)

        NotificationCenter.default.publisher(for: UIApplication.keyboardWillHideNotification)
            .compactMap({ $0.userInfo })
            .compactMap({ KeyboardInfo(userInfo: $0) })
            .map({ KeyboardChangeData(keyboardInfo: $0, offsetFromScreenBottom: 0.0) })
            .sink { [weak self] in
                self?.keyboardInfoSubject.send($0)
            }.store(in: &keyboardCancellables)
    }
}

// MARK: - Helper extensions
extension KeyboardListeningViewController {
    struct KeyboardChangeData {
        let keyboardInfo: KeyboardInfo
        let offsetFromScreenBottom: CGFloat
    }
}
