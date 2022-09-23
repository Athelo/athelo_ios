//
//  CommunitiesListViewModel.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 30/06/2022.
//

import Combine
import OrderedCollections
import UIKit

final class CommunitiesListViewModel: BaseViewModel {
    // MARK: - Constants
    enum Section {
        case leading
        case myCommunities
        case otherCommunities
        case loadMore
    }
    
    // MARK: - Properties
    private let dataSnapshotSubject = CurrentValueSubject<NSDiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier>?, Never>(nil)
    var dataSnapshotPublisher: AnyPublisher<NSDiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier>?, Never> {
        dataSnapshotSubject
            .eraseToAnyPublisher()
    }
    
    private let liveUpdateHandler = CommunitiesListLiveUpdateHandler()
    
    private let listItems = CurrentValueSubject<OrderedDictionary<Section, [ChatRoomData]>, Never>([:])
    private var nextPageURL: URL? = nil
    
    var canLoadMoreItems: Bool {
        !listItems.value.isEmpty && nextPageURL != nil
    }
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - Initialization
    override init() {
        super.init()
        
        sink()
        
        Task { [weak self] in
            await self?.liveUpdateHandler.registerListeners(forced: true)
        }
    }
    
    // MARK: - Public API
    func disableLiveUpdates() {
        Task { [weak self] in
            await self?.liveUpdateHandler.lockLiveUpdates()
        }
    }
    
    func enableLiveUpdates() {
        Task { [weak self] in
            await self?.liveUpdateHandler.unlockLiveUpdates()
        }
    }
    
    func item(at indexPath: IndexPath) -> ChatRoomCellConfigurationData? {
        guard let section = section(at: indexPath.section) else {
            return nil
        }
        
        return listItems.value[section]?[safe: indexPath.item]
    }
    
    func item(for roomID: Int) -> ChatRoomData? {
        listItems.value.values.flatMap({ $0 }).first(where: { $0.chatRoomID == roomID })
    }
    
    func loadMore() {
        guard canLoadMoreItems, state.value != .loading,
              let nextPageURL = nextPageURL else {
            return
        }
        
        state.send(.loading)
        
        (AtheloAPI.PageBased.nextPage(nextPageURL: nextPageURL) as AnyPublisher<ListResponseData<ChatRoomData>, APIError>)
            .sink { [weak self] result in
                self?.state.send(result.toViewModelState())
            } receiveValue: { [weak self] value in
                self?.nextPageURL = value.next
                self?.updateChatList(with: value.results)
            }.store(in: &cancellables)
    }
    
    func refresh() {
        guard state.value != .loading else {
            return
        }
        
        state.send(.loading)
        
        let request = ChatGroupConversationListRequest(isPublic: true)
        (AtheloAPI.Chat.groupConversationList(request: request) as AnyPublisher<ListResponseData<ChatRoomData>, APIError>)
            .sink { [weak self] result in
                self?.state.send(result.toViewModelState())
            } receiveValue: { [weak self] value in
                self?.nextPageURL = value.next
                self?.updateChatList(with: value.results, resetting: true)
            }.store(in: &cancellables)
    }
    
    func section(at index: Int) -> Section? {
        guard let snapshotSection = dataSnapshotSubject.value?.sectionIdentifiers[safe: index] else {
            return nil
        }
        
        switch snapshotSection {
        case .loadMore:
            return .loadMore
        case .leading:
            return .leading
        case .myCommunities:
            return .myCommunities
        case .otherCommunities:
            return .otherCommunities
        }
    }
    
    func sectionTitle(at index: Int) -> String? {
        guard let section = section(at: index) else {
            return nil
        }
        
        switch section {
        case .leading, .loadMore:
            return nil
        case .myCommunities:
            guard let itemCount = listItems.value[.myCommunities]?.count, itemCount > 0 else {
                return nil
            }
            
            let displayFlair = itemCount > 1
            return "community.list.section.my.\(displayFlair ? "multiple" : "single")".localized()
        case .otherCommunities:
            guard listItems.value[.otherCommunities]?.isEmpty == false else {
                return nil
            }
            
            let displayFlair = listItems.value[.myCommunities]?.isEmpty == false
            return "community.list.section.other.\(displayFlair ? "with" : "no")flair".localized()
        }
    }
    
    func joinCommunityWithChatRoomID(_ chatRoomID: Int) {
        guard state.value != .loading,
              let chatRoom = listItems.value[.otherCommunities]?.first(where: { $0.id == chatRoomID }), !chatRoom.belongTo else {
            return
        }
        
        state.send(.loading)
        
        let request = ChatJoinGroupConversationRequest(chatRoomID: chatRoom.id)
        Publishers.NetworkingPublishers.NeverWrappingPublisher(request: Deferred { AtheloAPI.Chat.joinGroupConversation(request: request) })
            .handleEvents(receiveOutput: { _ in
                DispatchQueue.main.async {
//                    NotificationUtility.checkNotificationAuthorizationStatus(in: UIApplication.shared)
                }
            })
            .flatMap({ _ -> AnyPublisher<ChatRoomData, APIError> in
                let request = ChatGroupConversationDetailsRequest(conversationID: chatRoom.id)
                return AtheloAPI.Chat.groupConversationDetails(request: request)
            })
            .sink { [weak self] result in
                self?.state.send(result.toViewModelState())
            } receiveValue: { [weak self] value in
                ChatUtility.registerChatRoomForPendingGreeting(value.chatRoomIdentifier)
                
                self?.updateChatRoomStatus([value])
            }.store(in: &cancellables)
    }
    
    func updateChatRoom(_ chatRoom: ChatRoomData) {
        guard state.value != .loading else {
            return
        }
        
        var allItems = listItems.value.values.flatMap({ $0 })
        guard let itemIndex = allItems.firstIndex(where: { $0.id == chatRoom.id }) else {
            return
        }
        
        allItems[itemIndex] = chatRoom
        
        updateChatList(with: allItems, resetting: true)
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoLiveUpdateHandler()
        sinkIntoOwnSubjects()
    }
    
    private func sinkIntoLiveUpdateHandler() {
        Task { [weak self] in
            guard let self = self else {
                return
            }
            
            await self.liveUpdateHandler.$updatedChatRooms
                .compactMap({ $0 })
                .sink(receiveValue: { [weak self] in
                    self?.updateChatRoomStatus($0)
                }).store(in: &self.cancellables)
        }
    }
    
    private func sinkIntoOwnSubjects() {
        listItems
            .map({ [weak self] in
                var snapshot = NSDiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier>()
                
                snapshot.appendSections([.leading])
                snapshot.appendItems([.leadingItemIdentifier()], toSection: .leading)
                
                if let myCommunities = $0[.myCommunities], !myCommunities.isEmpty {
                    let addedSection = SectionIdentifier.myCommunities(displaysFlair: myCommunities.count > 1)
                    
                    snapshot.appendSections([addedSection])
                    snapshot.appendItems(myCommunities.map({ ItemIdentifier(chatRoomData: $0) }), toSection: addedSection)
                }
                
                if let otherCommunities = $0[.otherCommunities], !otherCommunities.isEmpty {
                    let addedSection = SectionIdentifier.otherCommunities(displaysFlair: $0[.myCommunities]?.isEmpty == false)
                    
                    snapshot.appendSections([addedSection])
                    snapshot.appendItems(otherCommunities.map({ ItemIdentifier(chatRoomData: $0) }), toSection: addedSection)
                }
                
                if self?.nextPageURL != nil {
                    snapshot.appendSections([.loadMore])
                    snapshot.appendItems([.loadMoreIdentifier()])
                }
                
                return snapshot
            })
            .sink { [weak self] in
                self?.dataSnapshotSubject.send($0)
            }.store(in: &cancellables)
    }
    
    // MARK: - Updates
    private func updateChatList(with items: [ChatRoomData], resetting: Bool = false) {
        var myCommunities: [ChatRoomData] = resetting ? [] : listItems.value[.myCommunities] ?? []
        var otherCommunities: [ChatRoomData] = resetting ? [] : listItems.value[.otherCommunities] ?? []
        
        for item in items {
            if item.belongTo {
                myCommunities.append(item)
            } else {
                otherCommunities.append(item)
            }
        }
        
        var updatedCommunitiesList: OrderedDictionary<Section, [ChatRoomData]> = [:]
        if !myCommunities.isEmpty {
            updatedCommunitiesList.updateValue(myCommunities, forKey: .myCommunities)
        }
        if !otherCommunities.isEmpty {
            updatedCommunitiesList.updateValue(otherCommunities, forKey: .otherCommunities)
        }
        
        listItems.send(updatedCommunitiesList)
    }
    
    private func updateChatRoomStatus(_ chatRooms: [ChatRoomData]) {
        var allCommunities = (listItems.value[.myCommunities] ?? []) + (listItems.value[.otherCommunities] ?? [])
        for chatRoom in chatRooms {
            if let chatRoomIndex = allCommunities.firstIndex(where: { $0.id == chatRoom.id }) {
                allCommunities[chatRoomIndex] = chatRoom
            }
        }

        updateChatList(with: allCommunities, resetting: true)
    }
}

extension CommunitiesListViewModel {
    enum SectionIdentifier: Hashable {
        case leading
        case myCommunities(displaysFlair: Bool)
        case otherCommunities(displaysFlair: Bool)
        case loadMore
    }
    
    struct ItemIdentifier: Hashable {
        private let identifier: String
        
        fileprivate static func leadingItemIdentifier() -> ItemIdentifier {
            ItemIdentifier(identifier: "s:header")
        }
        
        fileprivate static func loadMoreIdentifier() -> ItemIdentifier {
            ItemIdentifier(identifier: "s:more")
        }
        
        private init(identifier: String) {
            self.identifier = identifier
        }
        
        init(chatRoomData: ChatRoomData) {
            self.identifier = "c:\(chatRoomData.id),\(chatRoomData.belongTo),\(chatRoomData.userProfiles.map({ "\($0.id)" }).joined(separator: "-"))"
        }
    }
}
