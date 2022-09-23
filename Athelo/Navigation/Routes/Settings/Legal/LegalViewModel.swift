//
//  LegalViewModel.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 21/07/2022.
//

import Combine
import UIKit

final class LegalViewModel: BaseViewModel {
    // MARK: - Constants
    private enum ModelError: LocalizedError {
        case emptyContents
        
        var errorDescription: String? {
            switch self {
            case .emptyContents:
                return "error.content".localized();
            }
        }
    }
    
    // MARK: - Properties
    let model = DescriptionModel()
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - Public API
    func assignConfigurationData(_ configurationData: LegalConfigurationData) {
        switch configurationData.source {
        case .publisher(let publisher):
            state.send(.loading)
            
            publisher
                .tryMap({
                    guard !$0.isEmpty else {
                        throw ModelError.emptyContents
                    }
                    
                    return $0
                })
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    self?.state.send($0.toViewModelState())
                } receiveValue: { [weak self] in
                    self?.model.updateDescription($0)
                }.store(in: &cancellables)
        case .text(let text):
            model.updateDescription(text)
        }
    }
}
