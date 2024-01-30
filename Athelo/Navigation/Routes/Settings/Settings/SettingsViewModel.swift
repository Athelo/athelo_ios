//
//  SettingsViewModel.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 21/07/2022.
//

import Combine
import UIKit

typealias SettingsAction = SettingsViewModel.Action

final class SettingsViewModel: BaseViewModel {
    // MARK: - Constants
    enum Action {
        case displayLegal(LegalConfigurationData)
        case displayPersonalInformation
    }
    
    // MARK: - Properties
    private let options = CurrentValueSubject<[SettingOption], Never>(SettingOption.displayedItems)
    var optionsUpdatePublisher: AnyPublisher<Void, Never> {
        options
            .map({ _ in () })
            .eraseToAnyPublisher()
    }
    
    var settingsConfigurationData: LegalConfigurationData? = nil
    
    private var action = CurrentValueSubject<String, Never>("")
    var actionUpdatePublisher: AnyPublisher<Void, Never> {
        action
            .map({ _ in () })
            .eraseToAnyPublisher()
    }
    
    // MARK: - Public API
    func action(at indexPath: IndexPath) -> SettingsAction? {
        guard let option = option(at: indexPath) else {
            return nil
        }
        
        switch option {
        case .aboutUs:
            let aboutUs = ConstantsStore.applicationData()?.aboutUs
            return .displayLegal(.init(title: "navigation.aboutus".localized(), source: aboutUs?.isEmpty == false ? .text(aboutUs!) : .publisher(
                ConstantsStore.applicationDataPublisher()
                    .tryMap({
                        guard let aboutUs: String = $0.aboutUs, !aboutUs.isEmpty else {
                            throw CommonError.missingContent
                        }
                        return aboutUs
                    })
                    .eraseToAnyPublisher()
            )))
        case .notifications:
            return nil
        case .personalInformation:
            return .displayPersonalInformation
        case .privacyPolicy:
            let privacyPolicy = ConstantsStore.applicationData()?.privacy
            return .displayLegal(.init(title: "navigation.privacypolicy".localized(), source: privacyPolicy?.isEmpty == false ? .text(privacyPolicy!) : .publisher(
                ConstantsStore.applicationDataPublisher()
                    .tryMap({
                        guard let privacyPolicy = $0.privacy, !privacyPolicy.isEmpty else {
                            throw CommonError.missingContent
                        }
                        
                        return privacyPolicy
                    })
                    .eraseToAnyPublisher()
            )))
        }
    }
    
    func configurationData(at indexPath: IndexPath) -> SettingCellConfigurationData? {
        guard let option = option(at: indexPath) else {
            return nil
        }
        
        return SettingCellConfigurationData(option: option, optionState: state(for: option))
    }
    
    func numberOfOptions() -> Int {
        options.value.count
    }
    
    func option(at indexPath: IndexPath) -> SettingOption? {
        options.value[safe: indexPath.row]
    }
    
    // MARK: - Updates
    private func state(for option: SettingOption) -> Bool? {
        switch option {
        case .aboutUs, .personalInformation, .privacyPolicy:
            return nil
        case .notifications:
            return false
        }
    }
}

// MARK: - Helper extensions
private extension SettingOption {
    static var displayedItems: [SettingOption] {
        [
            .personalInformation,
            .aboutUs,
            .privacyPolicy
        ]
    }
}

private extension Array where Element == SettingOption {
    static var displayedItems: [SettingOption] {
        SettingOption.displayedItems
    }
}
