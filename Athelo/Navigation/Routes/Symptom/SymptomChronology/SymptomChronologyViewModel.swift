//
//  SymptomChronologyViewModel.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 20/07/2022.
//

import Combine
import UIKit

final class SymptomChronologyViewModel: BaseViewModel {
    // MARK: - Properties
    let itemModel = SymptomsDailyListModel(items: [], shouldLoadMore: false)
    
    private let items = CurrentValueSubject<[SymptomDaySummaryData]?, Never>(nil)
    
    private var filterSymptomIDs: [Int]?
    private var nextPageURL: URL?
    var canLoadMore: Bool {
        nextPageURL != nil
    }
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - Initialization
    override init() {
        super.init()
        
        sink()
    }
    
    // MARK: - Public API
    func assignConfigurationData(_ configurationData: ModelConfigurationListData<SymptomData>) {
        switch configurationData {
        case .data(let data):
            assignFilterSymptoms(data)
        case .id(let ids):
            filterSymptomIDs = ids
        }
    }
    
    func assignFilterSymptoms(_ symptoms: [SymptomData]) {
        self.filterSymptomIDs = symptoms.map({ $0.id })
    }
    
    func loadMore() {
        guard state.value != .loading,
              let nextPageURL = nextPageURL else {
            return
        }
        
        state.send(.loading)
        
        (AtheloAPI.PageBased.nextPage(nextPageURL: nextPageURL) as AnyPublisher<ListResponseData<HealthSummaryData>, APIError>)
            .handleEvents(receiveOutput: { [weak self] in
                self?.nextPageURL = $0.next
            })
            .map({ $0.results.toPrintableData() })
            .sink { [weak self] in
                self?.state.send($0.toViewModelState())
            } receiveValue: { [weak self] value in
                self?.items.send((self?.items.value ?? []) + value)
            }.store(in: &cancellables)
    }
    
    func refresh() {
        guard state.value != .loading else {
            return
        }
        
        state.send(.loading)
        
        let request_ = HealthPerDaySummaryRequest(grouping: .bySymptoms)
        (AtheloAPI.Health.perDaySummary(request: request_) as AnyPublisher<ListResponseData<HealthSummaryData>, APIError>)
            .handleEvents(receiveOutput: { [weak self] in
                self?.nextPageURL = $0.next
            })
            .map { $0.results.toPrintableData() }
            .sink { [weak self] in
                self?.state.send($0.toViewModelState())
            } receiveValue: { [weak self] value in
                self?.items.send(value)
            }.store(in: &cancellables)
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoOwnSubjects()
    }
    
    private func sinkIntoOwnSubjects() {
        items
            .compactMap({ $0 })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                let shouldLoadMore = self?.canLoadMore == true
                self?.itemModel.updateItems($0, shouldLoadMore: shouldLoadMore)
            }.store(in: &cancellables)
    }
}

// MARK: - Helper extensions
private extension Array where Element == HealthSummaryData {
    func toPrintableData() -> [SymptomDaySummaryData] {
        var summaryData: [SymptomDaySummaryData] = []
        
        for data in self {
            var trimmedSymptomsList: [UserSymptomData] = []
            for symptom in data.symptoms {
                if !trimmedSymptomsList.contains(where: { $0.symptom.id == symptom.symptom.id }) {
                    trimmedSymptomsList.append(symptom)
                }
            }
            
            let feeling = data.feelings.sorted(by: \.id).last
            let addedData = SymptomDaySummaryData(date: data.occurrenceDate, symptoms: trimmedSymptomsList, feeling: feeling)
            
            summaryData.append(addedData)
        }
        
        return summaryData
    }
}
