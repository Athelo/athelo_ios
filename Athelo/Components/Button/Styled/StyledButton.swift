//
//  StyledButton.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 02/06/2022.
//

import Combine
import CombineCocoa
import UIKit

final class StyledButton: UIButton {
    // MARK: - Constants
    enum Style {
        case main
        case secondary
        case destructive
    }
    
    // MARK: - Outlets
    private weak var shadowCastingView: UIView?
    
    // MARK: - Inspectables
    @IBInspectable var alignImageToLeadingEdge: Bool = false {
        didSet {
            updateContentAlignment()
        }
    }
    
    @IBInspectable var destructiveStyle: Bool = false {
        didSet {
            if destructiveStyle == true {
                style = .destructive
            }
        }
    }
    
    @IBInspectable var secondaryStyle: Bool = false {
        didSet {
            if secondaryStyle == true {
                style = .secondary
            }
        }
    }
    
    @IBInspectable var imageTintColorOnActivation: UIColor? = nil {
        didSet {
            updateImageTinting()
        }
    }
    
    @IBInspectable var lightMainColor: Bool = false {
        didSet {
            updateBackgroundColor()
        }
    }
    
    // MARK: - Properties
    override var alpha: CGFloat {
        set {
            super.alpha = newValue
            shadowCastingView?.alpha = newValue
        }
        get {
            super.alpha
        }
    }
    
    override var isHidden: Bool {
        set {
            super.isHidden = newValue
            shadowCastingView?.isHidden = newValue
        }
        get {
            super.isHidden
        }
    }
    
    var style: Style = .main {
        didSet {
            UIView.performWithoutAnimation { [weak self] in
                self?.updateBackgroundColor()
                self?.updateImageTinting()
                self?.updateWithCurrentStyle()
            }
        }
    }
    
    private var cancellables: [AnyCancellable] = []

    // MARK: - View lifecycle
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        configure()
        sink()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
        sink()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.masksToBounds = true
        layer.cornerRadius = bounds.height / 2.0
        
        if alignImageToLeadingEdge {
            updateContentAlignment()
        }
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        guard superview != nil else {
            return
        }
        
        if shadowCastingView != nil {
            shadowCastingView?.removeFromSuperview()
            shadowCastingView = nil
        }
        
        let shadowCastingView = ShadowCastingView()
        
        shadowCastingView.backgroundColor = .clear
        shadowCastingView.translatesAutoresizingMaskIntoConstraints = false
        
        superview?.insertSubview(shadowCastingView, belowSubview: self)
        
        NSLayoutConstraint.activate([
            shadowCastingView.topAnchor.constraint(equalTo: topAnchor),
            shadowCastingView.bottomAnchor.constraint(equalTo: bottomAnchor),
            shadowCastingView.leftAnchor.constraint(equalTo: leftAnchor),
            shadowCastingView.rightAnchor.constraint(equalTo: rightAnchor)
        ])
        
        self.shadowCastingView = shadowCastingView
    }
    
    override func removeFromSuperview() {
        shadowCastingView?.removeFromSuperview()
        shadowCastingView = nil
        
        super.removeFromSuperview()
    }
    
    // MARK: - Public API
    func bindShadowCastingView(_ view: UIView?) {
        self.shadowCastingView = view
    }
    
    override func setTitle(_ title: String?, for state: UIControl.State) {
        super.setTitle(title, for: state)
        
        if alignImageToLeadingEdge {
            updateContentAlignment()
        }
    }
    
    // MARK: - Configuration
    private func configure() {
        configureOwnView()
    }
    
    private func configureOwnView() {
        adjustsImageWhenHighlighted = false
        
        titleLabel?.font = .withStyle(.button)
        
        updateBackgroundColor()
        updateContentAlignment()
        updateImageTinting()
        updateWithCurrentStyle()
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoStateChanges()
    }
    
    private func sinkIntoStateChanges() {
        publisher(for: \.isHighlighted)
            .removeDuplicates()
            .combineLatest(
                publisher(for: \.isEnabled)
                    .removeDuplicates()
            )
            .sinkDiscardingValue { [weak self] in
                self?.updateBackgroundColor()
                self?.updateImageTinting()
            }.store(in: &cancellables)
        
        publisher(for: \.isEnabled)
            .removeDuplicates()
            .sinkDiscardingValue { [weak self] in
                self?.updateShadowCastingView()
            }.store(in: &cancellables)
    }
    
    // MARK: - Updates
    private func updateBackgroundColor() {
        let animationTime = UIAccessibility.isReduceMotionEnabled ? 0.0 : style == .secondary ? 0.4 : 0.2
        UIView.transition(with: self, duration: animationTime, options: [.beginFromCurrentState]) { [weak self] in
            guard let self = self else {
                return
            }
            
            if self.state == .disabled {
                switch self.style {
                case .main:
                    self.backgroundColor = .withStyle(.purpleC1B4C0)
                case .secondary:
                    self.backgroundColor = .withStyle(.white)
                case .destructive:
                    self.backgroundColor = .withStyle(.redFF0000).adjustingHSBByPercentile(saturationChange: -0.5)
                }
            } else if self.state == .highlighted || self.state == .selected {
                switch self.style {
                case .main:
                    self.backgroundColor = .withStyle(.purple623E61)
                case .secondary:
                    self.backgroundColor = self.tintColor
                case .destructive:
                    self.backgroundColor = .systemRed
                }
            } else if self.state == .normal {
                switch self.style {
                case .main:
                    self.backgroundColor = self.lightMainColor ? .withStyle(.purple988098) : .withStyle(.purple80627F)
                case .secondary:
                    self.backgroundColor = .withStyle(.white)
                case .destructive:
                    self.backgroundColor = .withStyle(.redFF0000)
                }
            }
        }
    }
    
    private func updateContentAlignment() {
        if alignImageToLeadingEdge, let image = image(for: .normal) {
            contentHorizontalAlignment = .leading
            
            let imageInset = bounds.height / 4.0
            let titleInset = (bounds.width - (titleLabel?.bounds.width ?? 0.0)) / 2.0 - image.size.width
            
            if UIApplication.shared.userInterfaceLayoutDirection == .leftToRight {
                imageEdgeInsets = UIEdgeInsets(left: imageInset)
                titleEdgeInsets = UIEdgeInsets(left: titleInset)
            } else {
                imageEdgeInsets = UIEdgeInsets(right: imageInset)
                titleEdgeInsets = UIEdgeInsets(left: titleInset)
            }
        } else {
            contentHorizontalAlignment = .center
        }
    }
    
    private func updateImageTinting() {
        guard let color = imageTintColorOnActivation else {
            return
        }
        
        if state == .highlighted || state == .selected {
            setImage(image(for: .normal)?.withRenderingMode(.alwaysOriginal), for: .normal)
        } else {
            setImage(image(for: .normal)?.withRenderingMode(.alwaysTemplate).withTintColor(color), for: .normal)
        }
    }
    
    private func updateShadowCastingView() {
        guard shadowCastingView != nil else {
            return
        }
        
        let targetAlpha: CGFloat = state != .disabled ? 1.0 : 0.0
        guard shadowCastingView?.alpha != targetAlpha else {
            return
        }
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: [.beginFromCurrentState]) { [weak view = shadowCastingView] in
            view?.alpha = targetAlpha
        }
    }
    
    private func updateWithCurrentStyle() {
        setTitleColor(.withStyle(.white), for: .highlighted)
        setTitleColor(.withStyle(.white), for: .selected)
        
        switch style {
        case .main, .destructive:
            layer.borderColor = nil
            layer.borderWidth = 0.0
            
            setTitleColor(.withStyle(.white), for: .normal)
            setTitleColor(.withStyle(.white), for: .disabled)
        case .secondary:
            layer.borderColor = tintColor.cgColor
            layer.borderWidth = 2.0
            
            setTitleColor(tintColor, for: .normal)
            setTitleColor(tintColor.withAlphaComponent(0.5), for: .disabled)
        }
    }
}
