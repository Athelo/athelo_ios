//
//  ChatMessagesViewController.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 12/07/2022.
//

import Combine
import SwiftDate
import UIKit

final class ChatMessagesViewController: BaseViewController {
    // MARK: - Constants
    private static let bottomOffsetLeeway = UIFont.withStyle(.message).lineHeight * 1.24 * 2.0
    
    // MARK: - Outlets
    @IBOutlet private weak var collectionViewMessages: UICollectionView!
    
    // MARK: - Properties
    private let viewModel = ChatMessagesViewModel()
    
    private lazy var messagesDataSource = createMessagesCollectionViewDataSource()
    
    private var lastRegisteredCollectionViewWidth: CGFloat?
    private var cellHeightCache: [Int: CGFloat] = [:]
    
    private var cancellables: [AnyCancellable] = []
    private var frameChangesCancellable: AnyCancellable?
    private var offsetChangesCancellable: AnyCancellable?
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        sink()
    }
    
    // MARK: - Public API
    func applyBottomOffsetDifference(_ offsetDifference: CGFloat, animationCurve: UIView.AnimationCurve? = .easeInOut, animationTime: TimeInterval? = 0.2) {
        let currentContentOffset = collectionViewMessages.contentOffset
        let targetContentOffsetY = currentContentOffset.y + offsetDifference
        let targetContentOffset = CGPoint(x: currentContentOffset.x, y: targetContentOffsetY)

        let curve = animationCurve ?? .easeInOut
        let time = animationTime ?? 0.2
        
        let animator = UIViewPropertyAnimator(duration: time, curve: curve) { [weak self] in
            self?.collectionViewMessages.contentOffset = targetContentOffset
        }
        animator.startAnimation()
    }
    
    func fetchLastMessages() {
        viewModel.fetchLastMessages()
    }
    
    // MARK: - Configuration
    private func configure() {
        configureMessagesCollectionView()
    }
    
    private func configureMessagesCollectionView() {
        collectionViewMessages.register(ChatIncomingMessageCollectionViewCell.self)
        collectionViewMessages.register(ChatInfoMessageCollectionViewCell.self)
        collectionViewMessages.register(ChatOutgoingMessageCollectionViewCell.self)
        collectionViewMessages.register(SmallActionCollectionViewCell.self)
        
        collectionViewMessages.contentInset = .init(vertical: 16.0)
        
        collectionViewMessages.dataSource = messagesDataSource
        collectionViewMessages.delegate = self
        
        collectionViewMessages.keyboardDismissMode = .onDrag
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoApplicationLifetimeEvents()
        sinkIntoViewModel()
    }
    
    private func sinkIntoApplicationLifetimeEvents() {
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .receive(on: DispatchQueue.main)
            .sinkDiscardingValue { [weak self] in
                if self?.viewModel.isLoadingHistoryData == false {
                    self?.viewModel.fetchLastMessages()
                }
            }.store(in: &cancellables)
    }
    
    private func sinkIntoMessagesCollectionView() {
        frameChangesCancellable?.cancel()
        frameChangesCancellable = collectionViewMessages.publisher(for: \.bounds)
            .map({ $0.size.height })
            .removeDuplicates()
            .sinkDiscardingValue { [weak self] in
                if self?.hasBottomContentVisible() == true {
                    self?.scrollToLastVisibleItem(animated: true)
                }
            }
        
        offsetChangesCancellable?.cancel()
        offsetChangesCancellable = collectionViewMessages.publisher(for: \.contentOffset)
            .map({ $0.y <= 0.0 })
            .removeDuplicates()
            .filter({ $0 })
            .debounce(for: 0.1, scheduler: DispatchQueue.main)
            .sinkDiscardingValue { [weak viewModel = viewModel] in
                viewModel?.loadMoreMessages()
            }
    }
    
    private func sinkIntoViewModel() {
        let snapshotPublisher = viewModel.$itemSnapshot
            .compactMap({ $0 })
            .eraseToAnyPublisher()
        
        snapshotPublisher
            .first()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.messagesDataSource.apply($0.snapshot, animatingDifferences: false) {
                    self?.scrollToLastVisibleItem(animated: false)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        guard let self = self else {
                            return
                        }
                        
                        if self.collectionViewMessages.contentOffset.y + self.collectionViewMessages.frame.size.height < self.collectionViewMessages.contentSize.height {
                            self.scrollToLastVisibleItem(animated: true)
                        }
                    }
                }
                
                self?.sinkIntoMessagesCollectionView()
            }.store(in: &cancellables)
        
        snapshotPublisher
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                guard let self = self else {
                    return
                }
                
                let contentHeight = self.collectionViewMessages.contentSize.height
                let contentOffsetY = self.collectionViewMessages.contentOffset.y
                let hadDisplayedBottomContent = self.hasBottomContentVisible()
                
                let shouldAnimateDifferences = hadDisplayedBottomContent && value.appendedTimelines?.contains(.appendedNewerMessages) == true
                self.messagesDataSource.apply(value.snapshot, animatingDifferences: shouldAnimateDifferences)
                
                if hadDisplayedBottomContent {
                    self.scrollToLastVisibleItem(animated: true)
                } else if value.appendedTimelines?.contains(.appendedOlderMessages) == true {
                    let targetOffsetY = max(0.0, contentOffsetY + (self.collectionViewMessages.contentSize.height - contentHeight))
                    
                    UIView.transition(with: self.collectionViewMessages, duration: 0.2, options: [.beginFromCurrentState, .transitionCrossDissolve]) {
                        UIView.performWithoutAnimation {
                            self.collectionViewMessages.setContentOffset(.init(x: 0.0, y: targetOffsetY), animated: false)
                        }
                    }
                } else if self.viewModel.currentUserHasSentLastMessage() == true,
                          value.appendedTimelines?.contains(.appendedNewerMessages) == true {
                    self.scrollToLastVisibleItem()
                }
            }.store(in: &cancellables)
    }
    
    // MARK: - Updates
    private func createMessagesCollectionViewDataSource() -> UICollectionViewDiffableDataSource<ChatMessagesViewModel.SectionIdentifier, ChatMessagesViewModel.ItemIdentifier> {
        let dataSource = UICollectionViewDiffableDataSource<ChatMessagesViewModel.SectionIdentifier, ChatMessagesViewModel.ItemIdentifier>(collectionView: collectionViewMessages) { [weak self] collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .action(let action):
                let cell = collectionView.dequeueReusableCell(withClass: SmallActionCollectionViewCell.self, for: indexPath)
                
                if let self = self {
                    cell.assignDelegate(self)
                }
                
                cell.configure(.init(title: action.actionTitle, icon: action.actionIcon), indexPath: indexPath)
                
                return cell
            case .date(let date):
                let cell = collectionView.dequeueReusableCell(withClass: ChatInfoMessageCollectionViewCell.self, for: indexPath)
                
                cell.configure(.date(date), indexPath: indexPath)
                
                return cell
            case .message(let data):
                if data.message.isSystemMessage {
                    let cell = collectionView.dequeueReusableCell(withClass: ChatInfoMessageCollectionViewCell.self, for: indexPath)
                    
                    cell.configure(.message(data.message), indexPath: indexPath)
                    
                    return cell
                } else if data.displaysOwnMessage {
                    let cell = collectionView.dequeueReusableCell(withClass: ChatOutgoingMessageCollectionViewCell.self, for: indexPath)
                    
                    cell.configure(data, indexPath: indexPath)
                    
                    return cell
                } else {
                    let cell = collectionView.dequeueReusableCell(withClass: ChatIncomingMessageCollectionViewCell.self, for: indexPath)
                    
                    cell.configure(data, indexPath: indexPath)
                    
                    return cell
                }
            }
        }
        
        return dataSource
    }
    
    private func hasBottomContentVisible() -> Bool {
        // If content size is smaller than viewport itself, then yes, bottom content has to be visible.
        if collectionViewMessages.contentSize.height <= collectionViewMessages.bounds.size.height {
            return true
        }

        // If content offset is high enough (with a +/- offset), then bottom content also has to be visible.
        if ceil(collectionViewMessages.contentOffset.y + collectionViewMessages.frame.height + Self.bottomOffsetLeeway) >= floor(collectionViewMessages.contentSize.height) {
            return true
        }

        // Otherwise - no.
        return false
    }
    
    private func scrollToLastVisibleItem(animated: Bool = false) {
        guard let lastItemIdentifier = messagesDataSource.snapshot().itemIdentifiers.last,
              let lastItemIndexPath = messagesDataSource.indexPath(for: lastItemIdentifier) else {
            return
        }
        
        collectionViewMessages.scrollToItem(at: lastItemIndexPath, at: .bottom, animated: animated)
    }
}

// MARK: - Protocol conformance
// MARK: Configurable
extension ChatMessagesViewController: Configurable {
    typealias ConfigurationDataType = ChatRoomIdentifier
    
    func assignConfigurationData(_ configurationData: ChatRoomIdentifier) {
        viewModel.assignChatRoomIdentifier(configurationData)
    }
}

// MARK: Navigable
extension ChatMessagesViewController: Navigable {
    static var storyboardScene: StoryboardScene {
        .community
    }
}

// MARK: SmallActionCollectionViewCellDelegate
extension ChatMessagesViewController: SmallActionCollectionViewCellDelegate {
    func smallActionCollectionViewCellDelegateAsksToPerformAction(_ cell: SmallActionCollectionViewCell) {
        viewModel.sendHelloMessage()
    }
}

// MARK: - Helper extensions
private extension ChatMessagesViewModel.Action {
    var actionIcon: UIImage? {
        switch self {
        case .sayHello:
            return UIImage(named: "hand")
        }
    }
    
    var actionTitle: String {
        switch self {
        case .sayHello:
            return "action.sayhello".localized()
        }
    }
}

extension ChatMessagesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let itemIdentifier = messagesDataSource.itemIdentifier(for: indexPath) else {
            return .zero
        }
        
        let collectionViewWidth = collectionView.bounds.width
        
        if lastRegisteredCollectionViewWidth != collectionView.bounds.width {
            cellHeightCache.removeAll()
            lastRegisteredCollectionViewWidth = collectionView.bounds.width
        }
        
        if let cachedHeight = cellHeightCache[itemIdentifier.hashValue] {
            return .init(width: collectionView.bounds.width, height: cachedHeight)
        }
        
        var height: CGFloat = 0.0
        
        switch itemIdentifier {
        case .message(let data):
            if data.message.isSystemMessage {
                height += ceil(NSString(string: data.message.message ?? "").boundingRect(with: .init(width: collectionViewWidth - 64.0, height: .greatestFiniteMagnitude), options: [.usesLineFragmentOrigin], attributes: attributes(for: .withStyle(.messageInfo)), context: nil).height)
                height += 8.0
            } else {
                let horizontalOffset = data.displaysOwnMessage ? 80.0 : 130.0
                
                height += data.displaysSenderName ? 4.0 : 16.0
                
                if data.displaysSenderName, let displayName = data.message.userData?.displayName, !displayName.isEmpty {
                    height += ceil(NSString(string: displayName).boundingRect(with: .init(width: collectionViewWidth - horizontalOffset, height: .greatestFiniteMagnitude), options: [.usesLineFragmentOrigin], attributes: attributes(for: .withStyle(.subtitle)), context: nil).height) + 4.0
                }
                
                if let message = data.message.message, !message.isEmpty {
                    height += ceil(NSString(string: message).boundingRect(with: .init(width: collectionViewWidth - horizontalOffset, height: .greatestFiniteMagnitude), options: [.usesLineFragmentOrigin], attributes: attributes(for: .withStyle(.message)), context: nil).height)
                }
                
                height += data.displaysDate ? 24.0 : 16.0
                
                if data.displaysDate {
                    height += ceil(NSString(string: data.message.timestamp.asDateFrom1970(with: .nanoseconds).in(region: .current).toString(.time(.short))).boundingRect(with: .init(width: collectionViewWidth - horizontalOffset, height: .greatestFiniteMagnitude), options: [.usesLineFragmentOrigin], attributes: attributes(for: .withStyle(.subtitle)), context: nil).height)
                }
            }
        case .date(let date):
            height += ceil(NSString(string: date.toString(.date(.long))).boundingRect(with: .init(width: collectionViewWidth - 64.0, height: .greatestFiniteMagnitude), options: [.usesLineFragmentOrigin], attributes: attributes(for: .withStyle(.messageInfo)), context: nil).height)
            height += 8.0
        case .action:
            height = 34.0
        }
        
        cellHeightCache[itemIdentifier.hashValue] = height
        
        return .init(width: collectionView.bounds.width, height: height)
    }
    
    private func attributes(for font: UIFont) -> [NSAttributedString.Key: Any] {
        var attrs: [NSAttributedString.Key: Any] = [:]
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineHeightMultiple = 1.24
        
        attrs[.baselineOffset] = abs(font.ascender - font.capHeight) / 2.0 * (1.24 - 1.0)
        attrs[.font] = font
        attrs[.paragraphStyle] = paragraph
        
        return attrs
    }
}
