//
//  RegisterSymptomsViewModel.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 20/07/2022.
//

import Combine
import SwiftDate
import UIKit

final class RegisterSymptomsViewModel: BaseViewModel {
    // MARK: - Properties
    let selectedDateModel = SelectedDateModel(date: Date())
    
    @Published private(set) var feelingHeader: String?
    @Published private(set) var selectedSymptom: SymptomData?
    @Published private(set) var symptomsSnapshot: NSDiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier>?
    
    private let activeItemSubject = CurrentValueSubject<SymptomDaySummaryData?, Never>(nil)
    var activeItemPublisher: AnyPublisher<SymptomDaySummaryData?, Never> {
        activeItemSubject
            .eraseToAnyPublisher()
    }
    var activeItem: SymptomDaySummaryData? {
        activeItemSubject.value
    }
    
    private let isEditingSubject = CurrentValueSubject<Bool, Never>(false)
    var isEditingPublisher: AnyPublisher<Bool, Never> {
        isEditingSubject
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    var isEditing: Bool {
        isEditingSubject.value
    }
    
    private let items = CurrentValueSubject<[SymptomDaySummaryData]?, Never>(nil)
    
    let referenceDate = Date()
    private var symptomsCache: [SymptomData]?
    private var symptomNote: String?
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - Initialization
    override init() {
        super.init()
        
        sink()
    }
    
    // MARK: - Public API
    func addSelectedSymptom() {
        guard let selectedSymptom = selectedSymptom,
              state.value != .loading else {
            return
        }

        state.send(.loading)
        
        let request = HealthAddSymptomRequest(symptomID: selectedSymptom.id, occurrenceDate: selectedDateModel.date, note: symptomNote)
        sinkIntoSymptomDaySummaryPublisher({
            (AtheloAPI.Health.addUserSymptom(request: request) as AnyPublisher<CreatedSymptomData, APIError>)
                .map({ $0.occurrenceDate })
                .mapError({ $0 as Error })
                .flatMap({ RegisterSymptomsViewModel.symptomDaySummaryPublisher(at: $0) })
                .handleEvents(receiveOutput: { [weak self] in
                    LocalNotificationData.postNotification(.symptomSummaryDataUpdated, parameters: [.summaryData: $0])
                    
                    self?.selectedSymptom = nil
                })
                .eraseToAnyPublisher()
        }())
    }
    
    func assignSelectedSymptom(_ symptom: SymptomData) {
        self.selectedSymptom = symptom
    }
    
    func assignSymptomNote(_ note: String) {
        self.symptomNote = note
    }
    
    func refresh() {
        guard state.value != .loading else {
            return
        }
        
        state.send(.loading)
        
        let lowerDateBound = referenceDate.dateByAdding(-6, .day).date
        let upperDateBound = referenceDate
        let boundary: [QueryDateData] = [.lowerBound(lowerDateBound, canBeEqual: true), .upperBound(upperDateBound, canBeEqual: true)]
        
        let feelingsRequest = HealthUserFeelingsRequest(occurrenceDates: boundary)
        let symptomsRequest = HealthUserSymptomsRequest(occurrenceDates: boundary)
        
        Publishers.CombineLatest(
            Publishers.NetworkingPublishers.ListRepeatingPublisher(initialRequest: Deferred { AtheloAPI.Health.userFeelings(request: feelingsRequest) as AnyPublisher<ListResponseData<FeelingData>, APIError> }),
            Publishers.NetworkingPublishers.ListRepeatingPublisher(initialRequest: Deferred { AtheloAPI.Health.userSymptoms(request: symptomsRequest) as AnyPublisher<ListResponseData<UserSymptomData>, APIError> })
        )
        .map({ (feelings, symptoms) -> [SymptomDaySummaryData] in
            var data: [SymptomDaySummaryData] = []
            
            for offset in (-6...0) {
                let date = upperDateBound.dateByAdding(offset, .day).date
                
                let feeling = feelings.filter({ $0.occurrenceDate.compare(toDate: date, granularity: .day) == .orderedSame }).sorted(by: \.id).last
                let symptoms = symptoms.filter({ $0.occurrenceDate.compare(toDate: date, granularity: .day) == .orderedSame })
                
                data.append(.init(date: date, symptoms: symptoms, feeling: feeling))
            }
            
            return data
        })
        .sink { [weak self] in
            self?.state.send($0.toViewModelState())
        } receiveValue: { [weak self] in
            self?.items.send($0)
        }.store(in: &cancellables)
    }
    
    func registerFeelingValue(_ value: Float) {
        guard state.value != .loading else {
            return
        }
        
        state.send(.loading)
        
        let reportDate = selectedDateModel.date
        let generalFeeling = FeelingScale(value: value).toGeneralFeeling()
        
        let request = HealthAddFeelingRequest(generalFeeling: generalFeeling, occurrenceDate: reportDate)
        sinkIntoSymptomDaySummaryPublisher({
            (AtheloAPI.Health.addUserFeeling(request: request) as AnyPublisher<FeelingData, APIError>)
                .mapError({ $0 as Error })
                .flatMap({ _ in RegisterSymptomsViewModel.symptomDaySummaryPublisher(at: reportDate) })
                .handleEvents(receiveOutput: {
                    LocalNotificationData.postNotification(.symptomSummaryDataUpdated, parameters: [.summaryData: $0])
                })
                .eraseToAnyPublisher()
        }())
    }
    
    func removeSymptom(with id: Int) {
        guard let symptom = symptom(with: id),
              state.value != .loading else {
            return
        }
        
        state.send(.loading)
        
        let symptomReportingDate = symptom.occurrenceDate
        
        let request = HealthDeleteSymptomRequest(symptomID: id)
        sinkIntoSymptomDaySummaryPublisher({
            Publishers.NetworkingPublishers.NeverWrappingPublisher(request: Deferred { AtheloAPI.Health.deleteSymptom(request: request) })
                .mapError({ $0 as Error })
                .flatMap({ _ in RegisterSymptomsViewModel.symptomDaySummaryPublisher(at: symptomReportingDate) })
                .handleEvents(receiveOutput: {
                    LocalNotificationData.postNotification(.symptomSummaryDataUpdated, parameters: [.summaryData: $0])
                })
                .eraseToAnyPublisher()
        }())
    }
    
    func switchEditingState() {
        isEditingSubject.value.toggle()
    }
    
    func symptomData(at indexPath: IndexPath) -> UserSymptomData? {
        activeItem?.symptoms[safe: indexPath.item]
    }
    
    func symptomDecorationData(at indexPath: IndexPath) -> PillCellDecorationData? {
        guard let symptomData = symptomData(at: indexPath) else {
            return nil
        }

        return .init(text: symptomData.symptom.name, itemIdentifier: symptomData.id, displaysRemoveAction: isEditing)
    }
    
    func symptom(with id: Int) -> UserSymptomData? {
        activeItem?.symptoms.first(where: { $0.id == id })
    }
    
    func symptomListPublisher() -> AnyPublisher<[ListInputCellItemData], Error> {
        if let cachedSymptoms = symptomsCache, !cachedSymptoms.isEmpty {
            return Just(cachedSymptoms)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        let request = HealthSymptomsRequest()
        return Publishers.NetworkingPublishers.ListRepeatingPublisher(initialRequest: Deferred { AtheloAPI.Health.symptoms(request: request) as AnyPublisher<ListResponseData<SymptomData>, APIError> })
            .map({
                $0.sorted(by: \.name) { lhs, rhs in
                    lhs.localizedCaseInsensitiveCompare(rhs) == .orderedAscending
                }
            })
            .handleEvents(receiveOutput: { [weak self] in
                self?.symptomsCache = $0
            })
            .map({ $0 as [ListInputCellItemData] })
            .mapError({ $0 })
            .eraseToAnyPublisher()
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoOwnSubjects()
    }
    
    private func sinkIntoOwnSubjects() {
        Publishers.CombineLatest(
            items.compactMap({ $0 }),
            selectedDateModel.$date
        )
        .compactMap({ (items, date) -> SymptomDaySummaryData? in
            items.first(where: { $0.date.compare(toDate: date, granularity: .day) == .orderedSame })
        })
        .sink { [weak self] in
            self?.activeItemSubject.send($0)
        }.store(in: &cancellables)
        
        Publishers.CombineLatest(
            activeItemSubject,
            isEditingSubject
        )
        .map({ (item, isEditing) -> NSDiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier> in
            var snapshot = NSDiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier>()
            
            if let symptoms = item?.symptoms, !symptoms.isEmpty {
                snapshot.appendSections([.symptoms])
                snapshot.appendItems(symptoms.map({ ItemIdentifier(symptom: $0, canBeEdited: isEditing) }))
            }
            
            return snapshot
        })
        .sink { [weak self] in
            self?.symptomsSnapshot = $0
        }.store(in: &cancellables)
        
        activeItemSubject
            .compactMap({ value -> String? in
                return "symptoms.track.header.wellbeing".localized()
            })
            .removeDuplicates()
            .sink { [weak self] in
                self?.feelingHeader = $0
            }.store(in: &cancellables)
    }
    
    private func sinkIntoSymptomDaySummaryPublisher(_ publisher: AnyPublisher<SymptomDaySummaryData, Error>) {
        publisher
            .sink { [weak self] result in
                self?.state.send(result.toViewModelState())
            } receiveValue: { [weak self] value in
                guard var currentItems = self?.items.value,
                      let replacedItemIndex = currentItems.firstIndex(where: { $0.date.compare(toDate: value.date, granularity: .day) == .orderedSame }) else {
                    return
                }
                
                currentItems[replacedItemIndex] = value
                
                self?.items.send(currentItems)
            }.store(in: &cancellables)
    }
    
    // MARK: - Updates
    static func symptomDaySummaryPublisher(at date: Date) -> AnyPublisher<SymptomDaySummaryData, Error> {
        let queryDate = QueryDateData.specificDates([date])
        
        let feelingsRequest = HealthUserFeelingsRequest(occurrenceDates: [queryDate])
        let symptomsRequest = HealthUserSymptomsRequest(occurrenceDates: [queryDate])
        
        return Publishers.CombineLatest(
            Publishers.NetworkingPublishers.ListRepeatingPublisher(initialRequest: Deferred { AtheloAPI.Health.userFeelings(request: feelingsRequest) as AnyPublisher<ListResponseData<FeelingData>, APIError> }),
            Publishers.NetworkingPublishers.ListRepeatingPublisher(initialRequest: Deferred { AtheloAPI.Health.userSymptoms(request: symptomsRequest) as AnyPublisher<ListResponseData<UserSymptomData>, APIError> })
        )
        .mapError({ $0 as Error })
        .map { (feelings, symptoms) -> SymptomDaySummaryData in
            let feeling = feelings.filter({ $0.occurrenceDate.compare(toDate: date, granularity: .day) == .orderedSame }).sorted(by: \.id).last
            let symptoms = symptoms.filter({ $0.occurrenceDate.compare(toDate: date, granularity: .day) == .orderedSame })
            
            return .init(date: date, symptoms: symptoms, feeling: feeling)
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - Helper extensions
extension RegisterSymptomsViewModel {
    enum SectionIdentifier: Hashable {
        case symptoms
    }
    
    struct ItemIdentifier: Hashable {
        private let identifier: String
        
        init(symptom: UserSymptomData, canBeEdited: Bool) {
            self.identifier = "s:\(symptom.id)-\(canBeEdited)"
        }
    }
}
