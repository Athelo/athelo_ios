//
//  PageProgressView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 08/06/2022.
//

import UIKit

final class PageProgressView: UIView {
    // MARK: - Constants
    private enum Constants {
        static let scaleRatio: CGFloat = 14.0 / 10.0
    }
    
    // MARK: - Outlets
    @IBOutlet private weak var stackViewDots: UIStackView!
    
    // MARK: - Inspectables
    @IBInspectable var numberOfPages: Int = 0 {
        didSet {
            updateVisibleDots()
            updateActivePage()
        }
    }
    
    // MARK: - Properties
    private(set) var activePage: Int = 0
    
    // MARK: - Initialization
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupFromNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupFromNib()
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
    
    // MARK: - Public API
    
    /// Marks selected page as active.
    ///
    /// Pages are indexed from 1.
    ///
    /// - Parameter page: Page to mark as selected. If page is the same as current active one, nothing happens.
    func markPageAsActive(_ page: Int) {
        guard page != activePage else {
            return
        }
        
        activePage = page
        updateActivePage(animated: true)
    }
    
    // MARK: - Configuration
    private func configure() {
        configureDotsStackView()
    }
    
    private func configureDotsStackView() {
        updateVisibleDots()
    }
    
    // MARK: - Updates
    private func updateVisibleDots() {
        guard let stackView = stackViewDots else {
            return
        }
        
        let shadowViews = subviews.filter({ $0 is ShadowCastingView })
        shadowViews.forEach({
            $0.removeFromSuperview()
        })
        
        let dotViews = stackView.arrangedSubviews
        dotViews.forEach({
            $0.removeFromSuperview()
        })
        
        guard numberOfPages > 0 else {
            return
        }
        
        let dotHeight = bounds.height / Constants.scaleRatio
        for dotIdx in 0..<numberOfPages {
            let dotView = UIView()
            
            dotView.backgroundColor = .withStyle(.purple988098)
            dotView.translatesAutoresizingMaskIntoConstraints = false
            
            dotView.layer.masksToBounds = true
            dotView.layer.cornerRadius = dotHeight / 2.0
            
            dotView.heightAnchor.constraint(equalToConstant: dotHeight).isActive = true
            dotView.widthAnchor.constraint(equalTo: dotView.heightAnchor).isActive = true
            
            stackViewDots.addArrangedSubview(dotView)
            
            let shadowCastingView = ShadowCastingView()
            
            shadowCastingView.alpha = 0.0
            shadowCastingView.backgroundColor = .clear
            shadowCastingView.translatesAutoresizingMaskIntoConstraints = false
            shadowCastingView.tag = dotIdx + 1
            
            insertSubview(shadowCastingView, belowSubview: stackViewDots)
            
            NSLayoutConstraint.activate([
                shadowCastingView.centerXAnchor.constraint(equalTo: dotView.centerXAnchor),
                shadowCastingView.centerYAnchor.constraint(equalTo: dotView.centerYAnchor),
                shadowCastingView.heightAnchor.constraint(equalTo: dotView.heightAnchor),
                shadowCastingView.widthAnchor.constraint(equalTo: shadowCastingView.heightAnchor)
            ])
        }
    }
    
    private func updateActivePage(animated: Bool = false) {
        guard stackViewDots != nil else {
            return
        }
        
        let animationTime = animated ? 0.2 : 0.0
        
        UIView.animate(withDuration: animationTime, delay: 0.0, options: [.beginFromCurrentState]) { [weak self] in
            guard let self = self else {
                return
            }
            
            for dotIdx in 0..<self.numberOfPages {
                guard let dotView = self.stackViewDots.arrangedSubviews[safe: dotIdx] else {
                    continue
                }
                
                let isActive = dotIdx + 1 == self.activePage
                
                let targetAlpha: CGFloat = isActive ? 1.0 : 0.5
                let targetScale = isActive ? Constants.scaleRatio : 1.0
                let targetTransform: CGAffineTransform = .init(scaleX: targetScale, y: targetScale)
                
                dotView.alpha = targetAlpha
                dotView.transform = targetTransform
                
                self.viewWithTag(dotIdx + 1)?.alpha = isActive ? 1.0 : 0.0
            }
        }
    }
}
