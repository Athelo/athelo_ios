//
//  MenuViewModel.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 09/06/2022.
//

import Combine
import UIKit

final class MenuViewModel: BaseViewModel {
    // MARK: - Properties
    @Published private(set) var listSnapshot: NSDiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier>?
    @Published private(set) var userAvatar: LoadableImageData?
    @Published private(set) var userName: String?
    
    private let displayedOptions = CurrentValueSubject<[MenuOption], Never>(MenuOption.inMenuOrder())
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - Initialization
    override init() {
        super.init()
        
        sink()
    }
    
    // MARK: - Public API
    func option(at indexPath: IndexPath) -> MenuOption? {
        displayedOptions.value[safe: indexPath.row]
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoOwnSubjects()
        sinkIntoUserStore()
    }
    
    private func sinkIntoOwnSubjects() {
        displayedOptions
            .map {
                var snapshot = NSDiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier>()
                
                snapshot.appendSections([.options])
                snapshot.appendItems($0.map({ ItemIdentifier(option: $0) }), toSection: .options)
                
                return snapshot
            }.sink { [weak self] in
                self?.listSnapshot = $0
            }.store(in: &cancellables)
    }
    
    private func sinkIntoUserStore() {
        IdentityUtility.userDataPublisher
            .compactMap({ $0?.displayName })
            .filter({ !$0.isEmpty })
            .removeDuplicates()
            .sink { [weak self] in
                self?.userName = $0
            }.store(in: &cancellables)
        
        IdentityUtility.userDataPublisher
            .receive(on: DispatchQueue.main)
            .compactMap({ $0?.avatarImage(in: .init(width: 32.0, height: 32.0)) })
            .removeDuplicates()
            .sink { [weak self] in
                self?.userAvatar = $0
            }.store(in: &cancellables)
    }
}

// MARK: - Helper extensions
private extension MenuOption {
    static func inMenuOrder() -> [Self] {
        [
            .myProfile,
            // Disabled for now.
//            .messages,
            .mySymptoms,
            // Disabled for now, restore once caregiver functionality will become available.
//            .myCaregivers,
//            .inviteACaregiver,
            .settings,
            .connectSmartWatch,
            .askAthelo,
            .sendFeedback
        ]
    }
}

extension MenuViewModel {
    enum SectionIdentifier: Hashable {
        case options
    }
    
    struct ItemIdentifier: Hashable {
        let identifier: String
        
        init(option: MenuOption) {
            self.identifier = option.rawValue
        }
    }
}
