//
//  SymptomDetailsPopupView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 21/07/2022.
//

import Combine
import CombineCocoa
import UIKit

typealias SymptomDetailsPopupConfigurationData = SymptomDetailsPopupView.ConfigurationData

protocol SymptomDetailsPopupViewDelegate: AnyObject {
    func symptomDetailsPopupViewAsksToClose(_ popupView: SymptomDetailsPopupView)
    func symptomDetailsPopupViewAsksToPerformAction(_ popupView: SymptomDetailsPopupView)
}

final class SymptomDetailsPopupView: UIView {
    // MARK: - Constants
    private enum Constants {
        static let descriptionLineHeight: CGFloat = UIFont.withStyle(.textField).lineHeight * 1.03
    }
    
    // MARK: - Outlets
    @IBOutlet private weak var buttonAction: UIButton!
    @IBOutlet private weak var labelPrompt: UILabel!
    @IBOutlet private weak var labelSymptomName: UILabel!
    @IBOutlet private weak var labelSymptomPlaceholder: UILabel!
    @IBOutlet private weak var stackViewContent: UIStackView!
    @IBOutlet private weak var stackViewDescription: UIStackView!
    @IBOutlet private weak var stackViewHeader: UIStackView!
    @IBOutlet private weak var textViewDescription: UITextView!
    @IBOutlet private weak var viewDescriptionShadowView: UIView!
    @IBOutlet private weak var viewDescriptionContainer: RoundedView!
    
    // MARK: - Constraints
    @IBOutlet private weak var constraintTextViewDescriptionHeight: NSLayoutConstraint!
    @IBOutlet private weak var constraintTextViewDescriptionLeading: NSLayoutConstraint!
    @IBOutlet private weak var constraintTextViewDescriptionTop: NSLayoutConstraint!
    
    // MARK: - Properties
    private(set) var isEditing: Bool = false
    private(set) var symptom: SymptomData?
    var note: String? {
        textViewDescription.text
    }
    
    private weak var delegate: SymptomDetailsPopupViewDelegate?
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - View lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configure()
        sink()
    }
    
    // MARK: - Public API
    func assignDelegate(_ delegate: SymptomDetailsPopupViewDelegate) {
        self.delegate = delegate
    }
    
    // MARK: - Configuration
    private func configure() {
        configureContentStackView()
        configureDescriptionTextView()
    }
    
    private func configureContentStackView() {
        stackViewContent.setCustomSpacing(40.0, after: stackViewHeader)
        stackViewContent.setCustomSpacing(64.0, after: stackViewDescription)
    }
    
    private func configureDescriptionTextView() {
        textViewDescription.addToolbar()
        textViewDescription.removePadding()
        
        textViewDescription.delegate = self
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoDescriptionTextView()
        sinkIntoKeyboardChanges()
    }
    
    private func sinkIntoDescriptionTextView() {
        textViewDescription.currentTextPublisher
            .debounce(for: 0.1, scheduler: DispatchQueue.main)
            .compactMap({ [weak self] _ -> CGFloat? in
                var contentHeight: CGFloat = ceil(self?.textViewDescription.contentSize.height ?? 0.0)
                if self?.isEditing == true {
                    contentHeight = max(Constants.descriptionLineHeight, contentHeight)
                }
                
                return contentHeight
            })
            .removeDuplicates()
            .sink { [weak self] value in
                let shouldAnimate = self?.isEditing == true
                UIView.animate(withDuration: shouldAnimate ? 0.2 : 0.0, delay: 0.0, options: [.beginFromCurrentState]) {
                    self?.constraintTextViewDescriptionHeight.constant = value
                    self?.layoutIfNeeded()
                }
            }.store(in: &cancellables)
        
        textViewDescription.currentTextPublisher
            .map({ $0?.isEmpty == false })
            .removeDuplicates()
            .map({ $0 ? 0.0 : 1.0 })
            .receive(on: DispatchQueue.main)
            .assign(to: \.alpha, on: labelSymptomPlaceholder)
            .store(in: &cancellables)
    }
    
    private func sinkIntoKeyboardChanges() {
        NotificationCenter.default.publisher(for: UIApplication.keyboardWillChangeFrameNotification)
            .compactMap({ $0.userInfo })
            .compactMap({ KeyboardInfo(userInfo: $0) })
            .removeDuplicates { lhs, rhs in
                lhs.rect.minY == rhs.rect.minY
            }
            .sink { [weak self] value in
                let safeAreaOffset = AppRouter.current.window.safeAreaInsets.bottom - AppRouter.current.window.safeAreaInsets.top
                let yOffset = max(0.0, (UIScreen.main.bounds.height - value.rect.minY) / 2.0 + safeAreaOffset)
                let targetTransform = CGAffineTransform(translationX: 0.0, y: -yOffset)
                
                if let curve = value.animationCurve,
                   let time = value.animationTime {
                    let animator = UIViewPropertyAnimator(duration: time, curve: curve) {
                        self?.transform = targetTransform
                    }
                    animator.startAnimation()
                } else {
                    UIView.animate(withDuration: 0.2, delay: 0.0, options: [.beginFromCurrentState]) {
                        self?.transform = targetTransform
                    }
                }
            }.store(in: &cancellables)
    }
    
    // MARK: - Updates
    private func updateComponents(with configurationData: SymptomDetailsPopupConfigurationData) {
        labelSymptomName.text = configurationData.symptom.name
        labelPrompt.isHidden = !isEditing
        
        viewDescriptionShadowView.isHidden = !isEditing
        stackViewDescription.spacing = isEditing ? 8.0 : 16.0
        viewDescriptionContainer.backgroundColor = isEditing ? .withStyle(.white) : .clear
        
        let textViewOffset = isEditing ? 16.0 : 0.0
        constraintTextViewDescriptionLeading.constant = textViewOffset
        constraintTextViewDescriptionTop.constant = textViewOffset
        
        if isEditing {
            labelSymptomPlaceholder.isHidden = false
            textViewDescription.isHidden = false
            
            constraintTextViewDescriptionHeight.constant = Constants.descriptionLineHeight
            
            viewDescriptionContainer.maxCornerRadius = 30.0
        } else {
            textViewDescription.text = configurationData.availableDescription
            stackViewDescription.isHidden = textViewDescription.text?.isEmpty == true
            
            labelSymptomPlaceholder.isHidden = true
            
            viewDescriptionContainer.maxCornerRadius = .leastNonzeroMagnitude
        }
        
        buttonAction.setTitle(isEditing ? "action.save".localized() : "action.symptomsrecommendation".localized(), for: .normal)
    }
    
    // MARK: - Actions
    @IBAction private func actionButtonTapped(_ sender: Any) {
        delegate?.symptomDetailsPopupViewAsksToPerformAction(self)
    }
    
    @IBAction private func closeButtonTapped(_ sender: Any) {
        delegate?.symptomDetailsPopupViewAsksToClose(self)
    }
}

// MARK: - Protocol conformance
// MARK: Configurable
extension SymptomDetailsPopupView: Configurable {
    struct ConfigurationData {
        enum Mode {
            case edit
            case read(description: String?)
        }
        
        let symptom: SymptomData
        let mode: Mode
        
        fileprivate var isSetupToEdit: Bool {
            switch mode {
            case .edit:
                return true
            case .read:
                return false
            }
        }
        
        fileprivate var availableDescription: String? {
            switch mode {
            case .edit:
                return nil
            case .read(let description):
                return description
            }
        }
    }
    
    func assignConfigurationData(_ configurationData: SymptomDetailsPopupConfigurationData) {
        isEditing = configurationData.isSetupToEdit
        symptom = configurationData.symptom
        
        updateComponents(with: configurationData)
    }
}

// MARK: UITextViewDelegate
extension SymptomDetailsPopupView: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.textColor = .withStyle(.purple623E61)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.textColor = .withStyle(.black)
    }
}
