//
//  ChatMessagesViewModel.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 12/07/2022.
//

import Combine
import UIKit

final class ChatMessagesViewModel: BaseViewModel {
    // MARK: - Properties
    @Published private(set) var hasMoreHistoryData: Bool = false
    @Published private(set) var isLoadingHistoryData: Bool = false
    @Published private(set) var itemSnapshot: UpdatedSnapshotData?
    
    private let messagesData = CurrentValueSubject<MessagesData?, Never>(nil)
    private var observer: ChatRoomUtility?
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - Initialization
    override init() {
        super.init()
        
        sink()
    }
    
    // MARK: - Public API
    func assignChatRoomIdentifier(_ chatRoomIdentifier: ChatRoomIdentifier) {
        guard observer == nil else {
            return
        }
        
        let observer = ChatUtility.roomUtility(for: chatRoomIdentifier)
        self.observer = observer
        
        observer.$messages
            .compactMap({ $0 })
            .sink { [weak self] in
                let timelines: AppendedMessagesTimeline? = self?.timelineDifferencesBetweenCurrentMessages(and: $0)
                let messagesData: MessagesData = MessagesData(messages: $0, appendedTimelines: timelines)

                self?.messagesData.send(messagesData)
            }.store(in: &cancellables)
        
        observer.historyRequestPingbackPublisher
            .sink { [weak self] in
                switch $0 {
                case .historyRequested:
                    self?.isLoadingHistoryData = true
                case .historyPayloadAvailable:
                    self?.hasMoreHistoryData = true
                    self?.isLoadingHistoryData = false
                case .historyPayloadMissing:
                    self?.hasMoreHistoryData = false
                    self?.isLoadingHistoryData = false
                }
            }.store(in: &cancellables)
    }
    
    func containsLastMessage(within identifiers: [ItemIdentifier]) -> Bool {
        guard let lastMessage = messagesData.value?.messages?.last,
              identifiers.contains(where: { $0.decorationData?.message.messageID == lastMessage.messageID }) else {
            return false
        }
        
        return true
    }
    
    func currentUserHasSentLastMessage() -> Bool {
        messagesData.value?.messages?.last?.userIdentifier.sansApplicationCodeSuffix() == IdentityUtility.userData?.user?.username.sansApplicationCodeSuffix()
    }
    
    func fetchLastMessages() {
        guard ChatUtility.connectionState == .connected else {
            return
        }
        
        observer?.fetchMostRecentMessages()
    }
    
    func loadMoreMessages() {
        guard ChatUtility.connectionState == .connected,
              !isLoadingHistoryData, hasMoreHistoryData else {
            return
        }
        
        observer?.updateMessagesHistory()
    }
    
    func sendHelloMessage() {
        guard let roomIdentifier = observer?.roomIdentifier else {
            return
        }
        
        ChatUtility.sendMessage(.sendMessage(message: ChatUtility.Messages.helloMessage), chatRoomIdentifier: roomIdentifier)
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoApplicationLifetimeEvents()
        sinkIntoOwnSubjects()
    }
    
    private func sinkIntoApplicationLifetimeEvents() {
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .flatMap({ _ in
                ChatUtility.connectionStatePublisher
                    .filter({ $0 == .connected })
                    .first()
            })
            .sinkDiscardingValue { [weak self] in
                self?.observer?.fetchMostRecentMessages()
            }.store(in: &cancellables)
    }
    
    private func sinkIntoOwnSubjects() {
        messagesData
            .compactMap({ $0 })
            .combineLatest(
                Just(())
                    .eraseToAnyPublisher()
                    .merge(with:
                        ChatUtility.greetingStateUpdatePublisher
                            .filter({ [weak self] in
                                self?.observer?.roomIdentifier == $0
                            })
                            .map({ _ in () })
                            .debounce(for: 0.1, scheduler: DispatchQueue.main)
                    )
            )
            .map({ $0.0 })
            .map({ [weak self] value -> UpdatedSnapshotData in
                guard let messages = value.messages else {
                    return UpdatedSnapshotData(snapshot: NSDiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier>(), timelines: value.appendedTimelines)
                }

                let snapshot = ChatMessagesViewModel.convertMessagesIntoSnapshot(messages, chatRoomIdentifier: self?.observer?.roomIdentifier)
                
                return UpdatedSnapshotData(snapshot: snapshot, timelines: value.appendedTimelines)
            })
            .sink { [weak self] in
                self?.itemSnapshot = $0
            }.store(in: &cancellables)
    }
        
    // MARK: - Updates
    private static func convertMessagesIntoSnapshot(_ messages: [MessagingChatMessage], chatRoomIdentifier: ChatRoomIdentifier? = nil) -> NSDiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier> {
        var snapshot = NSDiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier>()
        
        let currentUserID: Int = IdentityUtility.userData?.id ?? -1
        for messageData in messages.enumerated() {
            let previousMessage = messages[safe: messageData.offset - 1]
            let nextMessage = messages[safe: messageData.offset + 1]
            
            var displayedDateMessage = false
            
            let messageDate = messageData.element.timestamp.asDateFrom1970(with: .nanoseconds)
            let isInTheSameDayAsPreviousMessage = previousMessage?.timestamp.asDateFrom1970(with: .nanoseconds).compare(toDate: messageDate, granularity: .day) == .orderedSame
            let isInTheSameDayAsNextMessage = nextMessage?.timestamp.asDateFrom1970(with: .nanoseconds).compare(toDate: messageDate, granularity: .day) == .orderedSame
            
            if previousMessage == nil || !isInTheSameDayAsPreviousMessage {
                snapshot.appendSections([.init(date: messageDate)])
                snapshot.appendItems([.date(messageDate)])
                
                displayedDateMessage = true
            }
            
            let hasSameSenderAsPreviousMessage = messageData.element.userData?.userProfileID == previousMessage?.userData?.userProfileID
            let hasSameSenderAsNextMessage = messageData.element.userData?.userProfileID == nextMessage?.userData?.userProfileID
            
            let displaysDate = !hasSameSenderAsNextMessage || !isInTheSameDayAsNextMessage
            let displaysOwnMessage = messageData.element.userData?.userProfileID == currentUserID
            let displaysSenderName = messageData.element.userData?.displayName?.isEmpty == false && (!hasSameSenderAsPreviousMessage || !isInTheSameDayAsPreviousMessage)
            
            let displaysAvatar = displaysOwnMessage ? false : !hasSameSenderAsNextMessage
            
            if displayedDateMessage || !hasSameSenderAsPreviousMessage || previousMessage == nil {
                snapshot.appendSections([.init(chatMessage: messageData.element)])
            }
            
            let decorationData = ChatMessageCellDecorationData(message: messageData.element, displaysAvatar: displaysAvatar, displaysDate: displaysDate, displaysOwnMessage: displaysOwnMessage, displaysSenderName: displaysSenderName)
            snapshot.appendItems([.message(decorationData)])
        }
        
        if let chatRoomIdentifier = chatRoomIdentifier,
           ChatUtility.shouldDisplayPendingGreetingButton(for: chatRoomIdentifier) {
            snapshot.appendSections([.init(action: .sayHello)])
            snapshot.appendItems([.action(.sayHello)])
        }
        
        return snapshot
    }
    
    private func timelineDifferencesBetweenCurrentMessages(and messages: [MessagingChatMessage]?) -> AppendedMessagesTimeline? {
        var timelines: AppendedMessagesTimeline? = nil
        
        guard let currentMessages = self.messagesData.value?.messages, !currentMessages.isEmpty,
              let messages = messages, !messages.isEmpty else {
            return timelines
        }
        
        if currentMessages.first?.messageID != messages.first?.messageID,
           let currentOldestMessageTimestamp = currentMessages.first?.timestamp,
           let updatedOldestMessageTimestamp = messages.first?.timestamp,
           updatedOldestMessageTimestamp < currentOldestMessageTimestamp {
            timelines = .appendedOlderMessages
        }
        
        if currentMessages.last?.messageID != messages.last?.messageID,
           let currentLatestMessageTimestamp = currentMessages.last?.timestamp,
           let updatedLatestMessageTimestamp = messages.last?.timestamp,
           updatedLatestMessageTimestamp > currentLatestMessageTimestamp {
            if timelines != nil{
                timelines?.insert(.appendedNewerMessages)
            } else {
                timelines = .appendedNewerMessages
            }
        }
        
        return timelines
    }
}

extension ChatMessagesViewModel {
    enum Action: String {
        case sayHello
    }
    
    struct SectionIdentifier: Hashable {
        let identifier: String
        
        init(action: Action) {
            self.identifier = "a:\(action.rawValue)"
        }
        
        init(chatMessage: MessagingChatMessage) {
            self.identifier = "m:\(chatMessage.messageID)-\(chatMessage.userIdentifier)"
        }
        
        init(date: Date) {
            self.identifier = "d:\(date.toChatTimestamp)"
        }
    }
    
    enum ItemIdentifier: Hashable {
        case action(Action)
        case date(Date)
        case message(ChatMessageCellDecorationData)
        
        func hash(into hasher: inout Hasher) {
            switch self {
            case .action(let action):
                hasher.combine(action.rawValue)
            case .date(let date):
                hasher.combine(date)
            case .message(let data):
                hasher.combine(data.message.messageID)
                hasher.combine(data.displaysAvatar)
                hasher.combine(data.displaysDate)
                hasher.combine(data.displaysOwnMessage)
                hasher.combine(data.displaysSenderName)
            }
        }
        
        static func == (lhs: ChatMessagesViewModel.ItemIdentifier, rhs: ChatMessagesViewModel.ItemIdentifier) -> Bool {
            switch ((lhs, rhs)) {
            case (.action(let lhsAction), .action(let rhsAction)):
                return lhsAction.rawValue == rhsAction.rawValue
            case (.message, .message):
                return lhs.hashValue == rhs.hashValue
            default:
                return false
            }
        }
        
        var action: Action? {
            switch self {
            case .action(let action):
                return action
            case .date, .message:
                return nil
            }
        }
        
        var date: Date? {
            switch self {
            case .date(let date):
                return date
            case .action, .message:
                return nil
            }
        }
        
        var decorationData: ChatMessageCellDecorationData? {
            switch self {
            case .message(let data):
                return data
            case .action, .date:
                return nil
            }
        }
    }
}

extension ChatMessagesViewModel {
    struct AppendedMessagesTimeline: OptionSet {
        let rawValue: Int

        static let appendedOlderMessages = AppendedMessagesTimeline(rawValue: 1 << 0)
        static let appendedNewerMessages = AppendedMessagesTimeline(rawValue: 1 << 1)
    }

    struct MessagesData {
        let appendedTimelines: AppendedMessagesTimeline?
        let messages: [MessagingChatMessage]?

        init(messages: [MessagingChatMessage]?, appendedTimelines: AppendedMessagesTimeline? = nil) {
            self.appendedTimelines = appendedTimelines
            self.messages = messages
        }
    }

    struct UpdatedSnapshotData {
        let appendedTimelines: AppendedMessagesTimeline?
        let snapshot: NSDiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier>

        init(snapshot: NSDiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier>, timelines: AppendedMessagesTimeline? = nil){
            self.appendedTimelines = timelines
            self.snapshot = snapshot
        }
    }
}
