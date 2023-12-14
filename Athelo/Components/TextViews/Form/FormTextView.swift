//
//  FormTextView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 23/06/2022.
//

import Combine
import CombineCocoa
import UIKit

@dynamicMemberLookup
final class FormTextView: UIView {
    // MARK: - Outlets
    @IBOutlet private weak var labelPlaceholder: UILabel!
    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet private weak var textView: UITextView!
    @IBOutlet private weak var viewContentContainer: UIView!
    @IBOutlet private weak var viewTextViewContainer: UIView!
    
    // MARK: - Constraints
    @IBOutlet private weak var constraintFormTextViewTop: NSLayoutConstraint!
    
    
    // MARK: - Inspectables
    @IBInspectable var fieldLocalizedTitle: String? {
        didSet {
            labelTitle.text = fieldLocalizedTitle?.localized()
        }
    }
    
    @IBInspectable var fieldLocalizedPlaceholder: String? {
        didSet {
            labelPlaceholder.text = fieldLocalizedPlaceholder?.localized()
        }
    }
    
    // MARK: - Properties
    override var isFirstResponder: Bool {
        textView.isFirstResponder
    }
    
    override var inputView: UIView? {
        get {
            textView.inputView
        }
        set {
            textView.inputView = newValue
        }
    }
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - Subscripts
    subscript<T>(dynamicMember keyPath: KeyPath<UITextView, T>) -> T {
        textView[keyPath: keyPath]
    }
    
    subscript<T>(dynamicMember keypath: WritableKeyPath<UITextView, T>) -> T {
        get {
            textView[keyPath: keypath]
        }
        set {
            textView[keyPath: keypath] = newValue
        }
    }
    
    // MARK: - View lifecycle
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupFromNib()
        
        configure()
        sink()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupFromNib()
        
        configure()
        sink()
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
        
        viewTextViewContainer.layer.masksToBounds = true
        viewTextViewContainer.layer.cornerRadius = min(24.0, viewTextViewContainer.bounds.height / 2.0)
    }
    
    // MARK: - Public API
    func addToolbar(withCustomToolbarIcons customToolbarIcons: [UIBarButtonItem]? = nil) {
        textView.addToolbar(withCustomToolbarIcons: customToolbarIcons)
    }
    
    @discardableResult
    override func becomeFirstResponder() -> Bool {
        return textView.becomeFirstResponder()
    }

    override var canBecomeFirstResponder: Bool {
        textView.canBecomeFirstResponder
    }
    
    func caretRect(for position: UITextPosition) -> CGRect {
        textView.caretRect(for: position)
    }
    
    func changePlaceholder(_ placeholder: String?) {
        labelPlaceholder.text = placeholder
    }
    
    func changeTitle(_ title: String?) {
        labelTitle.text = title
    }
    
    func containsInstanceOfTextView(_ textView: UITextView) -> Bool {
        self.textView === textView
    }
    
    @discardableResult
    override func resignFirstResponder() -> Bool {
        textView.resignFirstResponder()
    }
    
    // MARK: - Configuration
    private func configure() {
        configureTextView()
    }
    
    private func configureTextView() {
        textView.removePadding()
        textView.textContainerInset = .init(vertical: max(0.0, (45.0 - (textView.font?.lineHeight ?? 0.0)) / 2.0))
        
        textView.delegate = self
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoTextView()
    }
    
    private func sinkIntoTextView() {
        textView.currentTextPublisher
            .map({ $0?.isEmpty == false })
            .removeDuplicates()
            .assign(to: \.isHidden, on: labelPlaceholder)
            .store(in: &cancellables)
    }
}

// MARK: - Protocol conformance
// MARK: UITextViewDelegate
extension FormTextView: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.textColor = .withStyle(.purple623E61)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.textColor = .withStyle(.black)
    }
}
