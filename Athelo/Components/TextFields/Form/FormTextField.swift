//
//  FormTextField.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 01/06/2022.
//

import Combine
import CombineCocoa
import UIKit

protocol CustomFormTextFieldInputView: UIView {
    var maximumExpectedContainerHeight: CGFloat { get }
}

@dynamicMemberLookup
final class FormTextField: UIView {
    // MARK: - Constants
    enum Icon: Hashable {
        case calendar
        case secureEntry
        case verticalChevron
    }
    
    // MARK: - Outlets
    @IBOutlet private weak var labelFieldName: UILabel!
    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var viewContentContainer: UIView!
    @IBOutlet private weak var viewTextFieldContainer: UIView!
    
    private var inactive: Bool = false
    
    private var rightStackView: UIStackView? {
        self.rightView as? UIStackView
    }
    
    private func button(for icon: Icon) -> UIButton? {
        rightStackView?.subviews.first(where: { $0.tag == icon.viewTag }) as? UIButton
    }
    
    // MARK: - Constraints
    @IBOutlet private weak var constraintTextFieldLeading: NSLayoutConstraint!
    
    var textFieldBottomAnchor: NSLayoutYAxisAnchor {
        self.textField.bottomAnchor
    }
    
    var textFieldTopAnchor: NSLayoutYAxisAnchor {
        self.textField.topAnchor
    }
    
    // MARK: - Inspectables
    @IBInspectable var fieldLocalizedTitle: String? {
        didSet {
            labelFieldName.text = fieldLocalizedTitle?.localized()
        }
    }
    
    @IBInspectable var fieldLocalizedPlaceholder: String? {
        didSet {
            textField.placeholder = fieldLocalizedPlaceholder?.localized()
        }
    }
    
    // MARK: - Properties
    override var isFirstResponder: Bool {
        textField.isFirstResponder
    }
    
    override var inputView: UIView? {
        get {
            textField.inputView
        }
        set {
            textField.inputView = newValue
        }
    }
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - Subscripts
    subscript<T>(dynamicMember keyPath: KeyPath<UITextField, T>) -> T {
        textField[keyPath: keyPath]
    }

    subscript<T>(dynamicMember keyPath: WritableKeyPath<UITextField, T>) -> T {
        get {
            textField[keyPath: keyPath]
        }
        set {
            textField[keyPath: keyPath] = newValue
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
        
        viewTextFieldContainer.layer.masksToBounds = true
        viewTextFieldContainer.layer.cornerRadius = min(24.0, viewTextFieldContainer.bounds.height / 2.0)
        
//        constraintTextFieldLeading.constant = viewContentContainer.bounds.height / 3.0
    }
    
    // MARK: - Public API
    func activateIcon(_ icon: Icon, animated: Bool = true) {
        switch icon.activationState {
        case .image(let image):
            button(for: .calendar)?.setImage(image, for: .normal)
        case .rotation:
            rotateIcon(icon, angle: .init(value: 180.0, unit: .degrees), animated: animated)
        case .none:
            break
        }
    }
    
    func addToolbar(withCustomToolbarIcons customToolbarIcons: [UIBarButtonItem]? = nil) {
        textField.addToolbar(withCustomToolbarIcons: customToolbarIcons)
    }
    
    @discardableResult
    override func becomeFirstResponder() -> Bool {
        return textField.becomeFirstResponder()
    }

    override var canBecomeFirstResponder: Bool {
        textField.canBecomeFirstResponder
    }
    
    func changeTitle(_ title: String?) {
        labelFieldName.text = title
    }
    
    func clearErrorMarking(updatingInputTextColor: Bool = true) {
        labelFieldName.textColor = .withStyle(.gray)
        if updatingInputTextColor {
            self.textColor = self.isEditing ? .withStyle(.purple623E61) : UIFont.colorForStyle(.textField)
        }
    }
    
    func containsInstanceOfTextField(_ textField: UITextField) -> Bool {
        self.textField === textField
    }
    
    func deactivateIcon(_ icon: Icon, animated: Bool = true) {
        switch icon.activationState {
        case .image:
            button(for: icon)?.setImage(icon.image, for: .normal)
        case .rotation:
            rotateIcon(icon, angle: .init(value: 0.0, unit: .degrees), animated: animated)
        case .none:
            break
        }
    }
    
    func displayIcon(_ icon: Icon) -> AnyPublisher<Void, Never> {
        let button = UIButton()

        button.contentEdgeInsets = UIEdgeInsets(horizontal: 5.0, vertical: 5.0)
        button.setImage(icon.image, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit

        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
        button.widthAnchor.constraint(lessThanOrEqualToConstant: 44.0).isActive = true

        button.tag = icon.viewTag

        rightStackView?.addArrangedSubview(button)
        
        if let stackViewHeightAnchor = rightStackView?.heightAnchor {
            button.heightAnchor.constraint(equalTo: stackViewHeightAnchor).isActive = true
        }

        return button.tapPublisher
    }
    
    func enableSecureTextEntry() {
        guard button(for: .secureEntry) == nil else {
            return
        }
        
        displayIcon(.secureEntry)
            .sinkDiscardingValue { [weak self] in
                self?.isSecureTextEntry.toggle()
                
                if let button = self?.button(for: .secureEntry) {
                    let icon = self?.isSecureTextEntry == true ? UIImage(named: "eyeClosed") : UIImage(named: "eyeOpen")
                    button.setImage(icon, for: .normal)
                }
            }.store(in: &cancellables)
        
        self.isSecureTextEntry = true
    }
    
    func markError() {
        labelFieldName.textColor = .withStyle(.redFF0000)
        self.textColor = .withStyle(.redFF0000)
    }
    
    func markInactive() {
        viewTextFieldContainer.backgroundColor = .withStyle(.inactiveGray)
    }
    
    func rotateIcon(_ icon: Icon, angle: Measurement<UnitAngle> = .init(value: 0.0, unit: .degrees), animated: Bool = true) {
        guard let iconButton = rightStackView?.viewWithTag(icon.viewTag) else {
            return
        }
        
        let animationTime = animated ? 0.4 : 0.0
        let targetTransform: CGAffineTransform = .init(rotationAngle: angle.converted(to: .radians).value)
        
        UIView.animate(withDuration: animationTime, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.0, options: [.beginFromCurrentState]) {
            iconButton.transform = targetTransform
        }
    }
    
    @discardableResult
    override func resignFirstResponder() -> Bool {
        textField.resignFirstResponder()
    }
    
    // MARK: - Configuration
    private func configure() {
        configureRightView()
    }

    private func configureRightView() {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.setContentHuggingPriority(.required - 1, for: .horizontal)
        
        let widthBreakingConstraint = stackView.widthAnchor.constraint(equalToConstant: 0.0)
        widthBreakingConstraint.priority = .defaultLow
        widthBreakingConstraint.isActive = true
        
        self.rightView = stackView
        self.rightViewMode = .always
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoOwnSubjects()
    }
    
    private func sinkIntoOwnSubjects() {
        self.textPublisher
            .sinkDiscardingValue { [weak self] in
                self?.clearErrorMarking(updatingInputTextColor: false)
                self?.textColor = self?.isEditing == true ? .withStyle(.purple623E61) : UIFont.colorForStyle(.textField)
            }.store(in: &cancellables)
    }
}

// MARK: - Helper extensions
private extension FormTextField.Icon {
    enum ActivationState {
        case image(UIImage)
        case rotation
    }
    
    var activationState: ActivationState? {
        switch self {
        case .calendar:
            return .image(UIImage(named: "calendarSolid")!)
        case .secureEntry:
            return nil
        case .verticalChevron:
            return .rotation
        }
    }
    
    var image: UIImage {
        switch self {
        case .calendar:
            return UIImage(named: "calendar")!
        case .secureEntry:
            return UIImage(named: "eyeClosed")!
        case .verticalChevron:
            return UIImage(named: "arrowDown")!
        }
    }
    
    var viewTag: Int {
        hashValue
    }
}
