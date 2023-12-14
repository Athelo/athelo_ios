//
//  FeedbackViewController.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 23/06/2022.
//

import Combine
import UIKit

final class FeedbackViewController: KeyboardListeningViewController {
    // MARK: - Outlets
    @IBOutlet private weak var buttonSendFeedback: UIButton!
    @IBOutlet private weak var labelHeader: UILabel!
    @IBOutlet private weak var formTextFieldType: FormTextField!
    @IBOutlet private weak var formTextViewMessage: FormTextView!
    @IBOutlet private weak var scrollViewContent: UIScrollView!
    @IBOutlet private weak var stackViewContent: UIStackView!
    
    private weak var feedbackTopicInputView: ListInputView?
    
    // MARK: - Constraints
    @IBOutlet private weak var constraintScrollViewContentBottom: NSLayoutConstraint!
    @IBOutlet private weak var constraintStackViewContentBottom: NSLayoutConstraint!
    
    // MARK: - Properties
    private let viewModel = FeedbackViewModel()
    private var router: FeedbackRouter?
    
    private var feedbackTopicDismissalGestureRecognizer: UITapGestureRecognizer?
    
    private var cancellables: [AnyCancellable] = []
    private var feedbackTopicInputCancellable: AnyCancellable?
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        sink()
    }
    
    // MARK: - Configuration
    private func configure() {
        configureContentStackView()
        configureMessageTextView()
        configureTypeTextField()
        configureOwnView()
    }
    
    private func configureContentStackView() {
        stackViewContent.setCustomSpacing(40.0, after: labelHeader)
    }
    
    private func configureMessageTextView() {
        formTextViewMessage.addToolbar()
    }
    
    private func configureTypeTextField() {
        formTextFieldType.delegate = self
    }
    
    private func configureOwnView() {
        title = "navigation.faq".localized()
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoKeyboardChanges()
        sinkIntoMessageTextView()
        sinkIntoTypeTextField()
        sinkIntoViewModel()
    }
    
    private func sinkIntoKeyboardChanges() {
        keyboardInfoPublisher
            .sink { [weak self] in
                if let self = self {
                    let targetOffset = $0.offsetFromScreenBottom > 0.0 ? 0.0 : -84.0
                    if targetOffset != self.constraintStackViewContentBottom.constant {
                        self.constraintStackViewContentBottom.constant = targetOffset
                    }
                    
                    self.adjustBottomOffset(using: self.constraintScrollViewContentBottom, keyboardChangeData: $0, additionalOffset: 84.0)
                }
            }.store(in: &cancellables)
    }
    
    private func sinkIntoMessageTextView() {
        formTextFieldType.returnPublisher
            .sink { [weak self] in
                self?.formTextViewMessage.resignFirstResponder()
            }.store(in: &cancellables)
        
        formTextViewMessage.currentTextPublisher
            .sink { [weak self] in
                self?.viewModel.assignText($0)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    self?.updateContentScrollViewOffsetBasedOnTextViewCaretPosition()
                }
            }.store(in: &cancellables)
    }
    
    private func sinkIntoTypeTextField() {
        formTextFieldType.displayIcon(.verticalChevron)
            .sink { [weak self] in
                if self?.feedbackTopicInputView == nil {
                    self?.displayFeedbackTopicInputView()
                } else {
                    self?.hideFeedbackTopicInputView()
                }
                
                self?.view.endEditing(true)
            }.store(in: &cancellables)
    }
    
    private func sinkIntoViewModel() {
        bindToViewModel(viewModel, cancellables: &cancellables)
        
        viewModel.$isValid
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .assign(to: \.isEnabled, on: buttonSendFeedback)
            .store(in: &cancellables)
        
        viewModel.$selectedFeedbackTopic
            .map({ $0?.name })
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .assign(to: \.text, on: formTextFieldType)
            .store(in: &cancellables)
        
        viewModel.state
            .filter({ $0 == .loaded })
            .receive(on: DispatchQueue.main)
            .sinkDiscardingValue { [weak formTextView = formTextViewMessage] in
                formTextView?.text = nil
            }.store(in: &cancellables)
    }
    
    // MARK: - Updates
    private func displayFeedbackTopicInputView() {
        guard feedbackTopicInputView == nil else {
            return
        }
        
        let inputView = ListInputView.instantiate()
        
        inputView.translatesAutoresizingMaskIntoConstraints = false
        inputView.alpha = 0.0
        
        scrollViewContent.addSubview(inputView)
        feedbackTopicInputView = inputView
        
        adjustFrameOfFormInputView(inputView, inRelationTo: formTextFieldType, inside: stackViewContent, of: scrollViewContent, estimatedComponentHeight: inputView.maximumExpectedContainerHeight)
        
        UIView.animate(withDuration: 0.3) {
            inputView.alpha = 1.0
        }
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(feedbackTopicInputViewDismissalGestureRecognized(_:)))
        tapGestureRecognizer.delegate = self
        
        if let oldGestureRecognizer = feedbackTopicDismissalGestureRecognizer {
            view.removeGestureRecognizer(oldGestureRecognizer)
        }
        view.addGestureRecognizer(tapGestureRecognizer)
        
        feedbackTopicDismissalGestureRecognizer = tapGestureRecognizer
        
        inputView.assignAndFireItemsPublisher(viewModel.feedbackTopicsPublisher(), preselecting: viewModel.selectedFeedbackTopic)
        
        feedbackTopicInputCancellable?.cancel()
        feedbackTopicInputCancellable = inputView.selectedItemPublisher
            .compactMap({ $0 as? FeedbackTopicData })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.viewModel.assignFeedbackTopic($0)
                
                self?.hideFeedbackTopicInputView()
                self?.view.endEditing(true)
            }
        
        view.endEditing(true)
        
        formTextFieldType.activateIcon(.verticalChevron)
    }
    
    private func hideFeedbackTopicInputView() {
        guard feedbackTopicInputView != nil else {
            return
        }
        
        if let feedbackTopicDismissalGestureRecognizer = feedbackTopicDismissalGestureRecognizer {
            view.removeGestureRecognizer(feedbackTopicDismissalGestureRecognizer)
        }
        
        formTextFieldType.deactivateIcon(.verticalChevron)
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.feedbackTopicInputView?.alpha = 0.0
        } completion: { [weak self] completed in
            if completed {
                self?.feedbackTopicInputView?.removeFromSuperview()
                self?.feedbackTopicInputView = nil
            }
        }
    }
    
    private func updateContentScrollViewOffsetBasedOnTextViewCaretPosition() {
        guard let selectedTextRange = formTextViewMessage.selectedTextRange,
              selectedTextRange.start == selectedTextRange.end else {
            return
        }

        let caretRect = formTextViewMessage.caretRect(for: selectedTextRange.start)
        let scrollViewRect = formTextViewMessage.convert(caretRect, to: scrollViewContent)

        let topCaretPosition = CGRect(origin: CGPoint(x: scrollViewRect.origin.x, y: scrollViewRect.minY), size: scrollViewRect.size)
        let bottomCaretPosition = CGRect(origin: CGPoint(x: scrollViewRect.origin.x, y: scrollViewRect.maxY + 24.0), size: scrollViewRect.size)

        scrollViewContent.scrollRectToVisible(topCaretPosition, animated: true)
        scrollViewContent.scrollRectToVisible(bottomCaretPosition, animated: true)
    }
    
    // MARK: - Actions
    @IBAction private func feedbackTopicInputViewDismissalGestureRecognized(_ sender: Any?) {
        guard (sender as? UITapGestureRecognizer) == feedbackTopicDismissalGestureRecognizer else {
            return
        }
        
        hideFeedbackTopicInputView()
    }
    
    @IBAction private func sendFeedbackButtonTapped(_ sender: Any) {
        view.endEditing(true)
        viewModel.sendRequest()
    }
}

// MARK: - Protocol conformance
// MARK: Configurable
extension FeedbackViewController: Configurable {
    struct ConfigurationData {
        let shouldPreselectQuestionCategory: Bool
        
        init(shouldPreselectQuestionCategory: Bool = false){
            self.shouldPreselectQuestionCategory = shouldPreselectQuestionCategory
        }
    }
    
    typealias ConfigurationDataType = ConfigurationData
    
    func assignConfigurationData(_ configurationData: ConfigurationData) {
        if configurationData.shouldPreselectQuestionCategory {
            viewModel.updatePreselectionToQuestionTopic()
        }
    }
}

// MARK: Navigable
extension FeedbackViewController: Navigable {
    static var storyboardScene: StoryboardScene {
        .feedback
    }
}

// MARK: Routable
extension FeedbackViewController: Routable {
    typealias RouterType = FeedbackRouter
    
    func assignRouter(_ router: FeedbackRouter) {
        self.router = router
    }
}

// MARK: UIGestureRecognizerDelegate
extension FeedbackViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let feedbackTopicInputView = feedbackTopicInputView,
           feedbackTopicInputView.bounds.contains(touch.location(in: feedbackTopicInputView)) {
            return false
        }
        
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: UITextFieldDelegate
extension FeedbackViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        !formTextFieldType.containsInstanceOfTextField(textField)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if formTextFieldType.containsInstanceOfTextField(textField) {
            if feedbackTopicInputView == nil {
                displayFeedbackTopicInputView()
            }
            
            view.endEditing(true)
            
            return false
        }
        
        return true
    }
}
