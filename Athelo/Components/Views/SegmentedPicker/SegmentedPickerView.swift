//
//  SegmentedPickerView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 04/07/2022.
//

import Combine
import UIKit

final class SegmentedPickerView: UIView {
    // MARK: - Constants
    private enum Constants {
        static let interOptionBaselineGap: CGFloat = 48.0
    }
    
    // MARK: - Properties
    private let selectedItemSubject = CurrentValueSubject<Int?, Never>(nil)
    var selectedItemPublisher: AnyPublisher<Int, Never> {
        selectedItemSubject
            .compactMap({ $0 })
            .eraseToAnyPublisher()
    }
    
    // MARK: - Outlets
    @IBOutlet private weak var stackViewOptions: UIStackView!
    @IBOutlet private weak var viewSelectedItem: UIView!
    
    // MARK: - Constraints
    @IBOutlet private weak var constraintViewSelectedItemCenterX: NSLayoutConstraint!
    @IBOutlet private weak var constraintViewSelectedItemWidth: NSLayoutConstraint!
    
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateSelectedItemViewWidth()
    }
    
    // MARK: - Public API
    func assignOptions(_ options: [String], preselecting preselectedOptionIndex: Int? = nil) {
        display(options: options, preselecting: preselectedOptionIndex)
    }
    
//    func manuallySelectOption(at index: Int, animated: Bool = false) {
//        selectOption(at: index, animated: animated, notifyPublisher: false)
//    }
    
    // MARK: - Updates
    private func display(options: [String], preselecting preselectedOptionIndex: Int? = nil) {
        let validOptions = options.filter({ !$0.isEmpty })
        guard validOptions.count > 1 else {
            return
        }
        
        let preexistingButtons = stackViewOptions.subviews
        for button in preexistingButtons {
            button.removeFromSuperview()
        }
        
        weak var weakSelf = self
        options.enumerated().forEach({ (idx, option) in
            let button = PickerButton()
            
            button.backgroundColor = .clear
            button.setTitleColor(.withStyle(.gray), for: .normal)
            button.translatesAutoresizingMaskIntoConstraints = false
            
            button.setTitle(option, for: .normal)
            button.tag = idx + 1
            
            stackViewOptions.addArrangedSubview(button)
            
            button.addTarget(weakSelf, action: #selector(optionButtonTapped(_:)), for: .touchUpInside)
        })
        
        setNeedsLayout()
        layoutIfNeeded()
        
        updateSelectedItemViewWidth()
        selectOption(at: preselectedOptionIndex ?? 0, animated: false)
    }
    
    private func interOptionGap() -> CGFloat {
        Constants.interOptionBaselineGap / max(1.0, CGFloat(stackViewOptions.subviews.count))
    }
    
    private func updateSelectedItemViewWidth() {
        let optionsCount = stackViewOptions.arrangedSubviews.count
        guard optionsCount > 1 else {
            return
        }
        
        let targetViewWidth = (bounds.width - (interOptionGap() * CGFloat(optionsCount - 1))) / CGFloat(optionsCount)
        guard targetViewWidth != constraintViewSelectedItemWidth.constant else {
            return
        }
        
        constraintViewSelectedItemWidth.constant = targetViewWidth
    }
    
    // MARK: - Actions
    @objc private func optionButtonTapped(_ sender: Any?) {
        guard let button = sender as? UIButton,
              button.tag > 0,
              stackViewOptions.arrangedSubviews.contains(button) else {
            return
        }
        
        selectOption(at: button.tag - 1)
    }
    
    private func selectOption(at index: Int, animated: Bool = true, notifyPublisher: Bool = true) {
        guard index != selectedItemSubject.value,
              let optionView = viewWithTag(index + 1) else {
            return
        }
        
        let optionFrame = stackViewOptions.convert(optionView.frame, to: self)
        let targetOffset = optionFrame.midX - bounds.midX
        
        let animationTime = animated ? 0.3 : 0.0
        UIView.animate(withDuration: animationTime, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.0, options: [.beginFromCurrentState]) { [weak self] in
            self?.constraintViewSelectedItemCenterX.constant = targetOffset
            self?.layoutIfNeeded()
        }
        
        if notifyPublisher {
            selectedItemSubject.send(index)
        }
    }
}
