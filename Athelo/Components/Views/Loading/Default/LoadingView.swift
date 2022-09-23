//
//  LoadingView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 31/05/2022.
//

import UIKit

final class LoadingView: UIView {
    // MARK: - Outlets
    @IBOutlet private weak var viewFirstDot: UIView!
    @IBOutlet private weak var viewSecondDot: UIView!
    @IBOutlet private weak var viewThirdDot: UIView!
    @IBOutlet private weak var viewFourthDot: UIView!
    
    // MARK: - Properties
    private var animator: UIViewPropertyAnimator?
    
    // MARK: - Initialization / lifecycle
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupFromNib()
        
        configure()
        startAnimating()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupFromNib()
        
        configure()
        startAnimating()
    }
    
    private func setupFromNib() {
        guard let view = Self.nib.instantiate(withOwner: self, options: nil).first as? UIView else {
            fatalError("Error loading \(self) from nib")
        }

        addSubview(view)
        view.frame = self.bounds
        
        superview?.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        superview?.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        superview?.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        superview?.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    deinit {
        animator?.stopAnimation(true)
    }
    
    // MARK: - Public API
    func changeDotColor(_ color: UIColor) {
        [viewFirstDot, viewSecondDot, viewThirdDot, viewFourthDot].forEach({
            $0?.backgroundColor = color
        })
    }
    
    // MARK: - Configuration
    private func configure() {
        configureDotViews()
    }
    
    private func configureDotViews() {
        [viewFirstDot, viewSecondDot, viewThirdDot, viewFourthDot].forEach({
            $0?.layer.cornerRadius = 4.0
            $0?.layer.masksToBounds = true
        })
    }
    
    // MARK: - Updates
    private func startAnimating() {
        animator?.stopAnimation(true)
        
        [viewFirstDot, viewSecondDot, viewThirdDot, viewFourthDot].forEach({
            $0?.alpha = 0.2
        })
        
        animator = UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 2.0, delay: 0.0, options: [.curveLinear]) { [weak self] in
            UIView.animateKeyframes(withDuration: 2.0, delay: 0.0) {
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.3) {
                    self?.viewFirstDot.alpha = 1.0
                }
                
                UIView.addKeyframe(withRelativeStartTime: 0.3, relativeDuration: 0.3) {
                    self?.viewFirstDot.alpha = 0.2
                }
                
                UIView.addKeyframe(withRelativeStartTime: (0.3 * 0.4), relativeDuration: 0.3) {
                    self?.viewSecondDot.alpha = 1.0
                }
                
                UIView.addKeyframe(withRelativeStartTime: (0.3 * 0.4) + 0.3, relativeDuration: 0.3) {
                    self?.viewSecondDot.alpha = 0.2
                }
                
                UIView.addKeyframe(withRelativeStartTime: (0.3 * 0.4 * 2.0), relativeDuration: 0.3) {
                    self?.viewThirdDot.alpha = 1.0
                }
                
                UIView.addKeyframe(withRelativeStartTime: (0.3 * 0.4 * 2.0) + 0.3, relativeDuration: 0.3) {
                    self?.viewThirdDot.alpha = 0.2
                }
                
                UIView.addKeyframe(withRelativeStartTime: (0.3 * 0.4 * 3.0), relativeDuration: 0.3) {
                    self?.viewFourthDot.alpha = 1.0
                }
                
                UIView.addKeyframe(withRelativeStartTime: (0.3 * 0.4 * 3.0) + 0.3, relativeDuration: 0.3) {
                    self?.viewFourthDot.alpha = 0.2
                }
            } completion: { [weak self] completed in
                self?.startAnimating()
            }
        }
    }
}
