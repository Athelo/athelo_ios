//
//  SymptomDescriptionViewModel.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 18/07/2022.
//

import Combine
import UIKit

final class SymptomDescriptionViewModel: BaseViewModel {
    // MARK: - Properties
    @Published private(set) var displaysChronologyButton: Bool = true
    let itemModel = SymptomListModel(entries: [])
    
    private(set) var configurationData: ModelConfigurationListData<SymptomData>?
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - Public API
    func assignConfigurationData(_ configurationData: SymptomDescriptionConfigurationData) {
        self.configurationData = configurationData.modelListData
        self.displaysChronologyButton = configurationData.displaysChronologyButton
        
        switch configurationData.modelListData {
        case .data(let data):
            itemModel.updateEntries(data)
        case .id(let ids):
            state.value = .loading
            
            let request = HealthSymptomsRequest(symptomIDs: ids)
            Publishers.NetworkingPublishers.ListRepeatingPublisher(initialRequest: Deferred { AtheloAPI.Health.symptoms(request: request) as AnyPublisher<ListResponseData<SymptomData>, APIError> })
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    self?.state.send($0.toViewModelState())
                } receiveValue: { [weak self] in
                    self?.itemModel.updateEntries($0)
                }.store(in: &cancellables)
        }
    }
}
