//
//  SymptomListViewModel.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 18/07/2022.
//

import Combine
import UIKit

final class SymptomListViewModel: BaseViewModel {
    // MARK: - Constants
    enum Filter: Int, CaseIterable {
        case all
        case mostUsed
        
        var name: String {
            switch self {
            case .all:
                return "symptoms.filter.all".localized()
            case .mostUsed:
                return "symptoms.filter.mostused".localized()
            }
        }
    }
    
    // MARK: - Properties
    let itemsModel = SymptomListModel(entries: [])
    
    private var data: [Filter: [SymptomData]] = [:]
    
    private let filterSubject = CurrentValueSubject<Filter, Never>(.all)
    var filterPublisher: AnyPublisher<Filter, Never> {
        filterSubject
            .eraseToAnyPublisher()
    }
    var filter: Filter {
        filterSubject.value
    }
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - Initialization
    override init() {
        super.init()
        
        sink()
    }
    
    // MARK: - Public API
    func detailsConfigurationData(for symptom: SymptomData) -> ModelConfigurationListData<SymptomData> {
        if let availableSymptom = data[.all]?.first(where: { $0.id == symptom.id }) {
            return .data([availableSymptom])
        }
        
        return .id([symptom.id])
    }
    
    func refresh() {
        guard state.value != .loading else {
            return
        }
        
        state.value = .loading
        
        Publishers.NetworkingPublishers.ListRepeatingPublisher(initialRequest: Deferred { AtheloAPI.Health.symptoms(request: .init()) as AnyPublisher<ListResponseData<SymptomData>, APIError> })
            .combineLatest(
                (AtheloAPI.Health.userSymptomsSummary() as AnyPublisher<[SymptomOccurrenceData], APIError>)
                    .map({ Array($0.sorted(by: \.occurrencesCount, using: >).map({ $0.symptom }).prefix(5)) })
                    .eraseToAnyPublisher()
            )
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.state.send($0.toViewModelState())
            } receiveValue: { [weak self] (allSymptoms, mostUsedSymptoms) in
                self?.data[.all] = allSymptoms.sorted(by: \.name) { lhs, rhs in
                    lhs.localizedCaseInsensitiveCompare(rhs) == .orderedAscending
                }
                self?.data[.mostUsed] = mostUsedSymptoms
                
                self?.updateVisibleItems()
            }.store(in: &cancellables)
    }
    
    func selectFilter(_ filter: Filter) {
        guard self.filter != filter else {
            return
        }
        
        filterSubject.send(filter)
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoOwnSubjects()
    }
    
    private func sinkIntoOwnSubjects() {
        filterSubject
            .dropFirst()
            .removeDuplicates()
            .sinkDiscardingValue { [weak self] in
                self?.updateVisibleItems()
            }.store(in: &cancellables)
    }
    
    // MARK: - Updates
    private func updateVisibleItems() {
        itemsModel.updateEntries(data[filter] ?? [])
    }
}
