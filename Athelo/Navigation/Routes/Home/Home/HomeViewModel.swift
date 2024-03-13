//
//  HomeViewModel.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 10/06/2022.
//

import Combine
import SwiftDate
import UIKit

protocol HomeDecorationData {
    /* ... */
}

typealias InteractableItemData = SectionTitleCollectionReusableView.InteractableItemData

final class HomeViewModel: BaseViewModel {
    // MARK: - Properties
    let selectedWardModel = SelectedWardModel()
    
    @Published private(set) var dataSnapshot: NSDiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier>?
    @Published private(set) var displaysWardSelection: Bool = false
    @Published private(set) var selectedInteractableItem: InteractableKey?
    
    private let sectionData = CurrentValueSubject<HomeLayoutData?, Never>(nil)
    private let symptomData = CurrentValueSubject<SymptomDaySummaryData?, Never>(nil)
    
    var numberOfSymptoms: Int {
        sectionData.value?.symptoms?.count ?? 0
    }
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - Initialization
    override init() {
        super.init()
        
        sink()
    }
    
    // MARK: - Public API
    func actionPrompt(at indexPath: IndexPath) -> RecommendationPrompt? {
        guard let section = section(at: indexPath.section) else {
            return nil
        }
        
        switch section {
        case .heading:
            return nil
        case .recommendations:
            guard let prompt = sectionData.value?.recommendations?[indexPath.item] else {
                return nil
            }
            
            return prompt
        case .wellBeing:
            return sectionData.value?.feeling != nil ? nil : .registerFeelings
        }
    }
    
    func assignSymptomSummaryData(_ data: SymptomDaySummaryData) {
        guard data.date.compare(toDate: Date(), granularity: .day) == .orderedSame else {
            return
        }
        
        let uniqueSymptoms = data.symptoms.uniqueByUnderlyingSymptomID()
        let updatedSummaryData = SymptomDaySummaryData(date: data.date, symptoms: uniqueSymptoms, feeling: data.feeling)
        
        symptomData.send(updatedSummaryData)
    }
    
    func checkActionableItemIdentifier(_ identifier: String) {
        guard let validItem = InteractableKey.allCases.first(where: { $0.rawValue == identifier }) else {
            return
        }
        
        self.selectedInteractableItem = validItem
    }
    
    func decorationData(at indexPath: IndexPath) -> HomeDecorationData? {
        guard let section = section(at: indexPath.section) else {
            return nil
        }
        
        switch section {
        case .heading:
            if let userName = IdentityUtility.userData?.displayName?.split(separator: " ").first {
                return HeadlineDecorationData(headline: "home.welcome.parametrized".localized(arguments: [String(userName)]))
            } else {
                return HeadlineDecorationData(headline: "home.welcome".localized())
            }
        case .recommendations:
            guard let recommendation = sectionData.value?.recommendations?[safe: indexPath.item] else {
                return nil
            }
            
            return TileDecorationData(recommendationPrompt: recommendation)
//        case .symptomAction:
//            return TileDecorationData(recommendationPrompt: .updateFeelings)
//        case .symptomList:
//            guard let symptom = sectionData.value?.symptoms?[indexPath.item] else {
//                return nil
//            }
//            
//            return PillCellDecorationData(text: symptom.name)
        case .wellBeing:
            if let feeling = sectionData.value?.feeling {
                return feeling
            }
            
            return TileDecorationData(recommendationPrompt: .registerFeelings)
        }
    }
    
    func headerSupplementaryData(at indexPath: IndexPath) -> SectionTitleDecorationData? {
        guard let section = section(at: indexPath.section) else {
            return nil
        }
        
        switch section {
        case .heading:
            return nil
        case .recommendations(let userRole):
            if let caregiverPatientData = userRole.relatedPatientData {
                let patientName = caregiverPatientData.contactDisplayName ?? "home.header.recommendations.caregiver.name.fallback".localized()
                return SectionTitleDecorationData(
                    title: "home.header.recommendations.caregiver".localized(arguments: [patientName]) /*,
                    interactableData: InteractableKey.allCases.map({ $0.interactableData }) */
                )
            } else {
                return SectionTitleDecorationData(title: "home.header.recommendations".localized())
            }
//        case .symptomAction, .symptomList:
//            return SectionTitleDecorationData(title: "home.header.symptoms".localized())
        case .wellBeing:
            return SectionTitleDecorationData(title: "home.header.wellbeing".localized())
        }
    }
    
    func section(at index: Int) -> SectionIdentifier? {
        dataSnapshot?.sectionIdentifiers[safe: index]
    }
    
    func refresh() {
        guard state.value != .loading else {
            return
        }
        
        let currentDate = Date()
        let queryDate = QueryDateData.specificDates([currentDate])
        
        let feelingsRequest = HealthUserFeelingsRequest(occurrenceDates: [queryDate])
        let symptomsRequest = HealthUserSymptomsRequest(occurrenceDates: [queryDate])
        
        Publishers.CombineLatest(
            Publishers.NetworkingPublishers.ListRepeatingPublisher(initialRequest: Deferred { AtheloAPI.Health.userFeelings(request: feelingsRequest) as AnyPublisher<ListResponseData<FeelingData>, APIError> }),
            Publishers.NetworkingPublishers.ListRepeatingPublisher(initialRequest: Deferred { AtheloAPI.Health.userSymptoms(request: symptomsRequest) as AnyPublisher<ListResponseData<UserSymptomData>, APIError> })
        )
        .mapError({ $0 as Error })
        .map { (feelings, symptoms) -> SymptomDaySummaryData in
            let referenceDate = currentDate.converted(to: .UTC)
            
            let feeling = feelings.filter({ $0.occurrenceDate.compare(toDate: referenceDate, granularity: .day) == .orderedSame }).sorted(by: \.id).last
            let symptoms = symptoms.filter({ $0.occurrenceDate.compare(toDate: referenceDate, granularity: .day) == .orderedSame })
            
            return .init(date: currentDate, symptoms: symptoms.uniqueByUnderlyingSymptomID(), feeling: feeling)
        }
        .sink { [weak self] in
            self?.state.send($0.toViewModelState())
        } receiveValue: { [weak self] in
            self?.symptomData.send($0)
        }.store(in: &cancellables)
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoIdentityUtility()
        sinkIntoLocalNotifications()
        sinkIntoOwnSubjects()
    }
    
    private func sinkIntoIdentityUtility() {
        IdentityUtility.userDataPublisher
            .filter({ $0 != nil })
            .compactMap({ [weak self] _ in
                self?.dataSnapshot
            })
            .filter({ $0.sectionIdentifiers.contains(.heading) })
            .sink { [weak self] in
                var snapshot = $0
                snapshot.reloadSections([.heading])
                
                self?.dataSnapshot = snapshot
            }.store(in: &cancellables)
        
//        IdentityUtility.$activeRole
//            .map({ $0?.relatedPatientData })
//            .sink { [weak self] value in
//                self?.selectedWardModel.updateWard(value)
//            }.store(in: &cancellables)
    }
    
    private func sinkIntoLocalNotifications() {
        LocalNotificationData.publisher(for: .symptomSummaryDataUpdated)
            .compactMap({ $0?.value(for: .summaryData) as? SymptomDaySummaryData })
            .sink { [weak self] in
                self?.assignSymptomSummaryData($0)
            }.store(in: &cancellables)
    }
    
    private func sinkIntoOwnSubjects() {
        Publishers.CombineLatest(
            symptomData,
            IdentityUtility.userDataPublisher
                .compactMap({ $0?.hasFitbitUserProfile })
                .removeDuplicates()
                .eraseToAnyPublisher()
//            IdentityUtility.$activeRole
//                .compactMap({ $0 })
//                .eraseToAnyPublisher()
        )
        .map({ (symptomData, hasConnectedDevice) -> HomeLayoutData in
            var recommendations: [RecommendationPrompt] = []
            
            
            recommendations.append(contentsOf: [
                .readArticles
//                .chatWithCommunity
            ])
            
            return HomeLayoutData(
                feeling: symptomData?.feeling?.feeling,
                symptoms: symptomData?.symptoms.map({ $0.symptom }),
                recommendations: recommendations,
                userRole: .patient
            )
        })
        .sink { [weak self] in
            self?.sectionData.send($0)
        }.store(in: &cancellables)
        
        sectionData
            .compactMap({ $0 })
            .sink { [weak self] in
                self?.rebuildSnapshot(using: $0)
            }.store(in: &cancellables)
        
        selectedWardModel.$selectedWard
            .map({ $0 != nil })
            .removeDuplicates()
            .sink { [weak self] value in
                self?.displaysWardSelection = value
            }.store(in: &cancellables)
    }
    
    // MARK: - Updates
    private func rebuildSnapshot(using layoutData: HomeLayoutData) {
        var snapshot = NSDiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier>()
        
        snapshot.appendSections([.heading])
        if let userName = IdentityUtility.userData?.displayName?.split(separator: " ").first {
            snapshot.appendItems([.init(sectionData: .heading("home.welcome.parametrized".localized(arguments: [String(userName)])))])
        } else {
            snapshot.appendItems([.init(sectionData: .heading("home.welcome".localized()))])
        }
        
        if !layoutData.userRole.isCaregiver {
            snapshot.appendSections([.wellBeing])
            if let feelingData = layoutData.feeling {
                snapshot.appendItems([.init(feelingScale: feelingData)])
            } else {
                snapshot.appendItems([.init(recommendationPrompt: .registerFeelings)])
            }
        }
        
        if let recommendations = layoutData.recommendations {
            snapshot.appendSections([.recommendations(layoutData.userRole)])
            snapshot.appendItems(recommendations.map({ ItemIdentifier(recommendationPrompt: $0) }))
        }
        
        dataSnapshot = snapshot
    }
}

// MARK: - Helper extensions
extension HomeViewModel {
    enum SectionIdentifier: Hashable {
        case heading
        case wellBeing
        case recommendations(ActiveUserRole)
    }
    
    struct ItemIdentifier: Hashable {
        private let identifier: String
        
        init(feelingScale: FeelingScale) {
            self.identifier = "feeling.\(feelingScale.self)"
        }
        
        init(recommendationPrompt: RecommendationPrompt) {
            self.identifier = "recommendation.\(recommendationPrompt.self).\(recommendationPrompt.isActionable)"
        }
        
        init(sectionData: SectionData) {
            self.identifier = "section.\(sectionData.self).\(sectionData.text)"
        }
        
        init(symptomData: SymptomData) {
            self.identifier = "symptom.\(symptomData.id)"
        }
    }
}

extension HomeViewModel {
    enum InteractableKey: String, CaseIterable {
        case recommendationCaregiverActivity
        case recommendationCaregiverSleep
        
        var substring: String {
            switch self {
            case .recommendationCaregiverActivity:
                return "home.header.recommendations.caregiver.activity".localized()
            case .recommendationCaregiverSleep:
                return "home.header.recommendations.caregiver.sleep".localized()
            }
        }
        
        var interactableData: InteractableItemData {
            InteractableItemData(key: self.rawValue, substring: self.substring)
        }
    }
    
    enum RecommendationPrompt {
//        case chatWithCommunity
//        case checkActivityLevels
//        case checkSleepLevels
    //    case connectDevice
        case readArticles
        case registerFeelings
        case updateFeelings
        
        var icon: UIImage {
            switch self {
//            case .chatWithCommunity:
//                return UIImage(named: "chatSolid")!
//            case .checkActivityLevels:
//                return UIImage(named: "lovedOneSolid")!
//            case .checkSleepLevels:
//                return UIImage(named: "moonSolid")!
//            case .connectDevice:
//                return UIImage(named: "watchSolid")!
            case .readArticles:
                return UIImage(named: "bookSolid")!
            case .registerFeelings:
                return UIImage(named: "laughSolid")!
            case .updateFeelings:
                return UIImage(named: "monitorSolid")!
            }
        }
        
        var recommendation: String {
            switch self {
//            case .chatWithCommunity:
//                return "home.recommendation.chatwithcommunity".localized()
//            case .checkActivityLevels:
//                return "home.recommendation.checkactivitylevels".localized()
//            case .checkSleepLevels:
//                return "home.recommendation.checksleeplevels".localized()
//            case .connectDevice:
//                return "home.recommendation.connectdevice".localized()
            case .readArticles:
                return "home.recommendation.readarticles".localized()
            case .registerFeelings:
                return "home.recommendation.registerfeelings".localized()
            case .updateFeelings:
                return "home.recommendation.updatefeelings".localized();
            }
        }
        
        var isActionable: Bool {
            true
        }
    }
    
    struct HomeLayoutData {
        let feeling: FeelingScale?
        let symptoms: [SymptomData]?
        let recommendations: [RecommendationPrompt]?
        let userRole: ActiveUserRole
    }
    
    enum SectionData: Hashable {
        case heading(String)
        case sectionTitle(String)
        
        var text: String {
            switch self {
            case .heading(let text), .sectionTitle(let text):
                return text
            }
        }
    }
}

private extension Date {
    static func timeZoneUnaware(in region: Region) -> Date {
        Date().converted(to: region)
    }
    
    func converted(to region: Region) -> Date {
        guard let convertedDate = Date(self.in(region: .current).toFormat("yyyy/MM/dd"), format: "yyyy/MM/dd", region: region) else {
            fatalError("Could not convert \(self) to \(region).")
        }
        
        return convertedDate
    }
}

extension FeelingScale: HomeDecorationData {
    /* ... */
}

extension HeadlineDecorationData: HomeDecorationData {
    /* ... */
}

extension PillCellDecorationData: HomeDecorationData {
    /* ... */
}

extension SectionTitleDecorationData: HomeDecorationData {
    /* ... */
}

extension TileDecorationData: HomeDecorationData {
    init(recommendationPrompt: HomeViewModel.RecommendationPrompt) {
        self.hasBackgroundDecoration = true
        self.icon = .image(recommendationPrompt.icon)
        self.isActionable = recommendationPrompt.isActionable
        self.style = .plain
        self.text = recommendationPrompt.recommendation
    }
}
