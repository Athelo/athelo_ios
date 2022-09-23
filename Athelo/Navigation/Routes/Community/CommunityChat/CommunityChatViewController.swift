//
//  CommunityChatViewController.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 11/07/2022.
//

import Combine
import CombineCocoa
import UIKit

final class CommunityChatViewController: KeyboardListeningViewController {
    // MARK: - Constants
    private enum Constants {
        static let chatActionsHiddenScale: CGFloat = 0.99
    }
    
    // MARK: - Outlets
    @IBOutlet private weak var buttonJoinCommunity: UIButton!
    @IBOutlet private weak var buttonLeave: UIButton!
    @IBOutlet private weak var buttonNotifications: UIButton!
    @IBOutlet private weak var buttonSendMessage: UIButton!
    @IBOutlet private weak var labelMessagePlaceholder: UILabel!
    @IBOutlet private weak var labelParticipantsCount: UILabel!
    @IBOutlet private weak var textViewMessage: UITextView!
    @IBOutlet private weak var stackViewContent: UIStackView!
    @IBOutlet private weak var viewActionsContainer: UIView!
    @IBOutlet private weak var viewChatContainer: UIView!
    @IBOutlet private weak var viewJoinCommunityActionContainer: UIView!
    @IBOutlet private weak var viewMessageBackground: UIView!
    @IBOutlet private weak var viewMessageContainer: UIView!
    
    private weak var chatViewController: ChatMessagesViewController?
    
    // MARK: - Constraints
    @IBOutlet private weak var constraintButtonJoinCommunityBottom: NSLayoutConstraint!
    @IBOutlet private weak var constraintStackViewContentBottom: NSLayoutConstraint!
    @IBOutlet private weak var constraintTextViewMessageHeight: NSLayoutConstraint!
    
    // MARK: - Properties
    private let viewModel = CommunityChatViewModel()
    private var router: CommunityChatRouter?
    
    var chatRoomidentifier: ChatRoomIdentifier? {
        viewModel.chatRoom?.chatRoomIdentifier
    }
    
    private var cancellables: [AnyCancellable] = []
    private var keyboardCancellables: [AnyCancellable] = []
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        sink()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        sinkIntoKeyboardChanges()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        view.endEditing(true)
        keyboardCancellables.cancelAndClear()
    }
    
    // MARK: - Configuration
    private func configure() {
        configureActionsContainerView()
        configureChatContainerView()
        configureContentStackView()
        configureLeaveButton()
        configureJoinCommunityButton()
        configureMessageTextView()
        configureNotificationsButton()
        configureOwnView()
        
        updateMessagingViewsVisibility(withMessagingAvailable: viewModel.chatRoom?.belongTo == true)
    }
    
    private func configureActionsContainerView() {
        viewActionsContainer.alpha = 0.0
        viewActionsContainer.transform = .init(scaleX: Constants.chatActionsHiddenScale, y: Constants.chatActionsHiddenScale)
    }
    
    private func configureChatContainerView() {
        guard chatViewController == nil else {
            return
        }
        
        let viewController = ChatMessagesViewController.viewController()
        
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.backgroundColor = .clear
        
        addChild(viewController)
        viewChatContainer.addSubview(viewController.view)
        
        viewController.view.stretchToSuperview()
        
        viewController.didMove(toParent: self)
        
        chatViewController = viewController
    }
    
    private func configureContentStackView() {
        stackViewContent.setCustomSpacing(0.0, after: viewChatContainer)
    }
    
    private func configureJoinCommunityButton() {
        let bottomOffset = max(0.0, 16.0 - AppRouter.current.window.safeAreaInsets.bottom)
        
        constraintButtonJoinCommunityBottom.constant = bottomOffset
    }
    
    private func configureLeaveButton() {
        buttonLeave.setImage(buttonLeave.image(for: .normal)?.withRenderingMode(.alwaysTemplate), for: .normal)
    }
    
    private func configureMessageTextView() {
        textViewMessage.removePadding()
    }
    
    private func configureNotificationsButton() {
        buttonNotifications.setImage(buttonNotifications.image(for: .normal)?.withRenderingMode(.alwaysTemplate), for: .normal)
    }
    
    private func configureOwnView() {
        title = viewModel.chatRoom?.name
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoMessageTextView()
        sinkIntoViewModel()
    }
    
    private func sinkIntoKeyboardChanges() {
        keyboardInfoPublisher
            .sink { [weak self] value in
                guard let self = self else {
                    return
                }
                
                self.adjustBottomOffset(using: self.constraintStackViewContentBottom, keyboardChangeData: value) { [weak self] (difference, curve, time) in
                    self?.chatViewController?.applyBottomOffsetDifference(difference, animationCurve: curve, animationTime: time)
                }
            }.store(in: &keyboardCancellables)
    }
    
    private func sinkIntoMessageTextView() {
        textViewMessage.textPublisher
            .map({ $0?.isEmpty == false })
            .removeDuplicates()
            .assign(to: \.isHidden, on: labelMessagePlaceholder)
            .store(in: &cancellables)
        
        textViewMessage.textPublisher
            .map({ $0?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false })
            .removeDuplicates()
            .map({ $0 ? 1.0 : 0.5 })
            .assign(to: \.alpha, on: buttonSendMessage)
            .store(in: &cancellables)
        
        textViewMessage.textPublisher
            .receive(on: DispatchQueue.main)
            .compactMap({ [weak self] _ in
                self?.textViewMessage.contentSize.height
            })
            .removeDuplicates()
            .sink { [weak self] value in
                UIView.animate(withDuration: 0.1, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.0, options: [.beginFromCurrentState]) {
                    self?.constraintTextViewMessageHeight.constant = value
                    self?.view.layoutIfNeeded()
                }
            }.store(in: &cancellables)
    }
    
    private func sinkIntoViewModel() {
        bindToViewModel(viewModel, cancellables: &cancellables)
        
        viewModel.$chatRoom
            .compactMap({ $0?.chatRoomIdentifier })
            .removeDuplicates()
            .sink { [weak viewController = chatViewController] in
                viewController?.assignConfigurationData($0)
            }.store(in: &cancellables)
        
        viewModel.$chatRoom
            .map({ $0?.name })
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.title = $0
            }.store(in: &cancellables)
        
        viewModel.$chatRoom
            .map({ $0?.belongTo == true })
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.updateChatActionsNavbarButtonVisiblity(value)
                UIView.animate(withDuration: 0.2, delay: 0.0, options: [.beginFromCurrentState]) {
                    self?.updateMessagingViewsVisibility(withMessagingAvailable: value)
                }
            }.store(in: &cancellables)
        
        viewModel.$participantsCount
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .assign(to: \.text, on: labelParticipantsCount)
            .store(in: &cancellables)
        
        viewModel.updatePromptPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.chatViewController?.fetchLastMessages()
            }.store(in: &cancellables)
    }
    
    // MARK: - Updates
    private func updateChatActionsVisiblity() {
        let targetAlpha = viewActionsContainer.alpha > 0.0 ? 0.0 : 1.0
        let targetScale = targetAlpha > 0.0 ? 1.0 : Constants.chatActionsHiddenScale
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: [.beginFromCurrentState]) { [weak self] in
            self?.viewActionsContainer.alpha = targetAlpha
            self?.viewActionsContainer.transform = .init(scaleX: targetScale, y: targetScale)
        }
    }
    
    private func updateChatActionsNavbarButtonVisiblity(_ isVisible: Bool) {
        if isVisible {
            weak var weakSelf = self
            let item = UIBarButtonItem(image: UIImage(named: "more"), style: .plain, target: weakSelf, action: #selector(chatActionsButtonTapped(_:)))
            
            navigationItem.setRightBarButton(item, animated: true)
        } else {
            navigationItem.setRightBarButton(nil, animated: true)
        }
    }
    
    private func updateMessagingViewsVisibility(withMessagingAvailable displayMessagingUI: Bool) {
        viewMessageContainer.isHidden = !displayMessagingUI
        viewMessageContainer.alpha = displayMessagingUI ? 1.0 : 0.0
        
        viewMessageBackground.isHidden = !displayMessagingUI
        viewMessageBackground.alpha = displayMessagingUI ? 1.0 : 0.0
        
        viewJoinCommunityActionContainer.isHidden = displayMessagingUI
        viewJoinCommunityActionContainer.alpha = displayMessagingUI ? 0.0 : 1.0
    }
    
    // MARK: - Actions
    @IBAction private func chatActionsButtonTapped(_ sender: Any) {
        updateChatActionsVisiblity()
    }
    
    @IBAction private func joinCommunityButtonTapped(_ sender: Any) {
        viewModel.joinCommunity()
    }
    
    @IBAction private func leaveButtonTapped(_ sender: Any) {
        let logOutAction = PopupActionData(title: "action.logout".localized()) { [weak self] in
            self?.viewModel.leaveCommunity()
        }
        let cancelAction = PopupActionData(title: "action.cancel".localized())
        
        AppRouter.current.windowOverlayUtility.displayPopupView(with: .init(template: .leaveCommunity, primaryAction: logOutAction, secondaryAction: cancelAction))
        
        updateChatActionsVisiblity()
    }
    
    @IBAction private func notificationsButtonTapped(_ sender: Any) {
        displayMessage("message.comingsoon".localized(), type: .plain)
        updateChatActionsVisiblity()
    }
    
    @IBAction private func sendMessageButtonTapped(_ sender: Any) {
        guard let message = textViewMessage.text, !message.isEmpty else {
            return
        }
        
        if viewModel.sendMessage(message) {
            textViewMessage.text = nil
        }
    }
}

// MARK: - Protocol conformance
// MARK: Configurable
extension CommunityChatViewController: Configurable {
    enum ConfigurationData {
        case data(ChatRoomData)
        case id(Int)
        case roomID(ChatRoomIdentifier)
    }
    
    func assignConfigurationData(_ configurationData: ConfigurationData) {
        viewModel.assignConfigurationData(configurationData)
    }
}

// MARK: Navigable
extension CommunityChatViewController: Navigable {
    static var storyboardScene: StoryboardScene {
        .community
    }
}

// MARK: Routable
extension CommunityChatViewController: Routable {
    func assignRouter(_ router: CommunityChatRouter) {
        self.router = router
    }
}
