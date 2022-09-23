//
//  AskAtheloViewModel.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 22/06/2022.
//

import Combine
import UIKit

final class AskAtheloViewModel: BaseViewModel {
    // MARK: - Properties
    let itemsModel = AskAtheloModel(entries: [])
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - Public API
    func refresh() {
        guard state.value != .loading else {
            return
        }
        
        state.send(.loading)
        
        let request = Deferred { AtheloAPI.FAQ.list() as AnyPublisher<ListResponseData<FAQItemData>, APIError> }
        Publishers.NetworkingPublishers.ListRepeatingPublisher(initialRequest: request)
            .map({ $0.map({ ExpandableEntryData(title: $0.question, content: $0.content) }) })
            .sink { [weak self] in
                self?.state.send($0.toViewModelState())
            } receiveValue: { [weak self] value in
                DispatchQueue.main.async {
                    self?.itemsModel.updateEntries(value)
                }
            }.store(in: &cancellables)
    }
}
