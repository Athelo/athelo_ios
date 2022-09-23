//
//  MyProfileBaseViewModel.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 13/06/2022.
//

import Combine
import OrderedCollections
import UIKit

final class MyProfileViewModel: BaseViewModel {
    // MARK: - Properties
    @Published private(set) var dataSnapshot: NSDiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier>?
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - Initialization
    override init() {
        super.init()
        
        sink()
    }
    
    // MARK: - Public API
    func deleteAccount() {
        guard state.value != .loading else {
            return
        }

        state.send(.loading)
        
        IdentityUtility.deleteAccount()
            .sink { [weak self] in
                self?.state.send($0.toViewModelState())
            }.store(in: &cancellables)
    }
    
    func headerSupplementaryData(at index: Int) -> SectionTitleDecorationData? {
        guard let section = section(at: index) else {
            return nil
        }
        
        switch section {
        case .profileDetails:
            return nil
        case .health:
            return SectionTitleDecorationData(title: "profile.header.health".localized(), font: .withStyle(.headline20))
        case .other:
            return SectionTitleDecorationData(title: "profile.header.other".localized(), font: .withStyle(.headline20))
        }
    }
    
    func item(at indexPath: IndexPath) -> ItemType? {
        guard let section = section(at: indexPath.section),
              case .option(let option) = dataSnapshot?.itemIdentifiers(inSection: section)[safe: indexPath.item] else {
            return nil
        }
        
        return option
    }
    
    func logOut() {
        IdentityUtility.logOut()
    }
    
    func refresh() {
        updateDataSnapshot()
    }
    
    func section(at index: Int) -> SectionIdentifier? {
        dataSnapshot?.sectionIdentifiers[safe: index]
    }
    
    func tile(at indexPath: IndexPath) -> TileDecorationData? {
        guard let option = item(at: indexPath) else {
            return nil
        }
        
        return option.tileDecorationData
    }
    
    func userProfileData() -> IdentityProfileData? {
        IdentityUtility.userData
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoIdentityUtility()
    }
    
    private func sinkIntoIdentityUtility() {
        IdentityUtility.userDataPublisher
            .filter({ $0 != nil })
            .compactMap({ [weak self] _ in
                self?.dataSnapshot
            })
            .filter({ $0.sectionIdentifiers.contains(.profileDetails) })
            .sink { [weak self] value in
                var snapshot = value
                snapshot.reloadSections([.profileDetails])
                
                self?.dataSnapshot = snapshot
            }.store(in: &cancellables)
        
        IdentityUtility.userDataPublisher
            .compactMap({ $0?.hasFitbitUserProfile })
            .removeDuplicates()
            .dropFirst()
            .sinkDiscardingValue { [weak self] in
                self?.updateDataSnapshot()
            }.store(in: &cancellables)
    }
    
    // MARK: - Updates
    private func updateDataSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier>()
        
        snapshot.appendSections([.profileDetails])
        snapshot.appendItems([.profile], toSection: .profileDetails)
        
        snapshot.appendSections([.health])
        snapshot.appendItems([.option(.trackMyWellbeing), .option(.mySymptoms)], toSection: .health)
        
        snapshot.appendSections([.other])
        if IdentityUtility.userData?.hasFitbitUserProfile == true {
            snapshot.appendItems([.option(.myDevice)], toSection: .other)
        }
        if IdentityUtility.authenticationMethods?.containsNativeAuthData() == true {
            snapshot.appendItems([.option(.changePassword)], toSection: .other)
        }
        snapshot.appendItems([.option(.logOut), .option(.deleteAnAccount)], toSection: .other)
        
        self.dataSnapshot = snapshot
    }
}

// MARK: - Helper extensions
extension MyProfileViewModel {
    enum ItemType {
        case changePassword
        case deleteAnAccount
        case logOut
        case myDevice
        case mySymptoms
        case trackMyWellbeing
        
        var tileDecorationData: TileDecorationData {
            TileDecorationData(text: tileTitle, style: tileStyle, icon: .image(tileIcon), isActionable: true, hasBackgroundDecoration: false)
        }
        
        private var tileIcon: UIImage {
            switch self {
            case .changePassword:
                return UIImage(named: "lockSolid")!
            case .deleteAnAccount:
                return UIImage(named: "personSolid")!
            case .logOut:
                return UIImage(named: "signOutSolid")!
            case .myDevice:
                return UIImage(named: "smartwatch")!
            case .mySymptoms:
                return UIImage(named: "monitorSolid")!
            case .trackMyWellbeing:
                return UIImage(named: "laughSolid")!
            }
        }
        
        private var tileStyle: TileDecorationData.Style {
            switch self {
            case .changePassword, .logOut, .myDevice, .mySymptoms, .trackMyWellbeing:
                return .plain
            case .deleteAnAccount:
                return .destructive
            }
        }
        
        private var tileTitle: String {
            switch self {
            case .changePassword:
                return "action.changepassword".localized()
            case .deleteAnAccount:
                return "action.deleteaccount".localized()
            case .logOut:
                return "action.logout".localized()
            case .myDevice:
                return "action.mydevice".localized()
            case .mySymptoms:
                return "action.mysymptoms".localized()
            case .trackMyWellbeing:
                return "action.trackmywellbeing".localized()
            }
        }
    }
}

extension MyProfileViewModel {
    enum SectionIdentifier: Hashable {
        case health
        case other
        case profileDetails
    }
    
    enum ItemIdentifier: Hashable {
        case profile
        case option(ItemType)
    }
}
