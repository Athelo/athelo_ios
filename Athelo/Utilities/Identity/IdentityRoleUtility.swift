//
//  IdentityRoleUtility.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 23/03/2023.
//

import Combine
import Foundation

enum ActiveUserRole: Codable, Equatable, Hashable {
    case patient
    case caregiver(IdentityCommonProfileData)
    
    var isCaregiver: Bool {
        relatedPatientData != nil
    }
    
    var relatedPatientData: IdentityCommonProfileData? {
        switch self {
        case .patient:
            return nil
        case .caregiver(let patient):
            return patient
        }
    }
    
    var relatedPatientID: Int? {
        relatedPatientData?.id
    }
}

final class IdentityRoleUtility {
    // MARK: - Constants
    private enum Keys: String, UserDefaultsBridge {
        case roles = "com.athelohealth.mobile.roles"
    }
    
    // MARK: - Properties
    @Published private(set) var activeRole: ActiveUserRole?
    @Published private(set) var caregivers: [ContactData]?
    @Published private(set) var patients: [ContactData]?
    
    private let caregiversAccessErrorSubject = PassthroughSubject<Error, Never>()
    private let patientsAccessErrorSubject = PassthroughSubject<Error, Never>()
    
    var caregiversAccessErrorPublisher: AnyPublisher<Error, Never> {
        caregiversAccessErrorSubject.eraseToAnyPublisher()
    }
    var patientsAccessErrorPublisher: AnyPublisher<Error, Never> {
        patientsAccessErrorSubject.eraseToAnyPublisher()
    }
    
    private var currentUserID: Int?
    
    private var caregiversRequestCancellable: AnyCancellable?
    private var patientsRequestCancellable: AnyCancellable?
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - Initialization
    init() {
        sink()
    }
    
    // MARK: - Public API
    func changeActiveRole(_ activeRole: ActiveUserRole) {
        updateRoleForCurrentUser(.patient)
        self.activeRole = .patient
    }
    
    func clearCachedData() {
        self.caregivers = nil
        self.patients = nil
        
        self.activeRole = nil
    }
    
    func resetRoleForActiveUser() {
        updateRoleForCurrentUser(nil)
        self.activeRole = nil
    }
    
    func updateActiveUser(_ user: IdentityProfileData?) {
        currentUserID = user?.id
        
        if currentUserID != nil {
            checkExistingRoleForCurrentUser()
            
            updateCaregiverDataForActiveUser()
            updatePatientDataForActiveUser()
        } else {
            caregiversRequestCancellable?.cancel()
            patientsRequestCancellable?.cancel()
            
            activeRole = nil
            caregivers = nil
            patients = nil
        }
    }
    
    @discardableResult func updateCaregiverDataForActiveUser() -> AnyPublisher<[ContactData], Error> {
        caregiversRequestCancellable?.cancel()
        return updateCaregiverListForCurrentUser()
    }
    
    @discardableResult func updatePatientDataForActiveUser() -> AnyPublisher<[ContactData], Error> {
        patientsRequestCancellable?.cancel()
        return updatePatientListForCurrentUser()
    }
    
    // MARK: - Role management
    private func checkExistingRoleForCurrentUser() {
        guard let roleData: Data = Keys.value(for: .roles),
              let roles = try? JSONDecoder().decode([Int: ActiveUserRole].self, from: roleData) else {
            return
        }
        
        guard let currentUserID, let lastKnownRole = roles[currentUserID] else {
            return
        }
        
        activeRole = .patient //lastKnownRole
    }
    
    private func updateRoleForCurrentUser(_ role: ActiveUserRole?) {
        guard let currentUserID else {
            return
        }
        
        var roleData: [Int: ActiveUserRole] = [:]
        if let storedRoleData: Data = Keys.value(for: .roles),
           let roles = try? JSONDecoder().decode([Int: ActiveUserRole].self, from: storedRoleData) {
            roleData = roles
        }
        
        roleData[currentUserID] = role
        
        if let updatedRoleData = try? JSONEncoder().encode(roleData) {
            Keys.setValue(ActiveUserRole.patient, for: .roles)
        }
    }
    
    // MARK: - Contacts management
    private func updateCaregiverListForCurrentUser() -> AnyPublisher<[ContactData], Error> {
        let request = AtheloAPI.Health.allCaregiversList().share()
        
        caregiversRequestCancellable = request
            .sink(receiveCompletion: { [weak self] result in
                if case .failure(let error) = result {
                    self?.caregiversAccessErrorSubject.send(error)
                }
            }, receiveValue: { [weak self] value in
                self?.caregivers = value
            })
        
        return request
            .map({ $0 as [ContactData] })
            .eraseToAnyPublisher()
    }
    
    private func updatePatientListForCurrentUser() -> AnyPublisher<[ContactData], Error> {
        let request = AtheloAPI.Health.allPatientsList().share()
        
        patientsRequestCancellable = request
            .sink(receiveCompletion: { [weak self] result in
                if case .failure(let error) = result {
                    self?.patientsAccessErrorSubject.send(error)
                }
            }, receiveValue: { [weak self] value in
                self?.patients = value
            })
        
        return request
            .map({ $0 as [ContactData] })
            .eraseToAnyPublisher()
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoOwnSubjects()
    }
    
    private func sinkIntoOwnSubjects() {
        Publishers.CombineLatest(
            $activeRole.map({ $0?.isCaregiver == true }),
            $patients.map({ $0?.isEmpty == true })
        )
        .map({ $0 && $1 })
        .removeDuplicates()
        .filter({ $0 })
        .receive(on: DispatchQueue.main)
        .sinkDiscardingValue { [weak self] in
            self?.resetRoleForActiveUser()
            self?.displayLostCaregiverPriviledgesPrompt()
        }.store(in: &cancellables)
    }
    
    // MARK: - Updates
    private func displayLostCaregiverPriviledgesPrompt() {
        let okAction = PopupActionData(
            title: "action.ok".localized(),
            customStyle: .main,
            action: {
                Task {
                    await AppRouter.current.exchangeRoot(.roleSelection)
                }
            }
        )
        
        let configurationData = PopupConfigurationData(
            title: "role.caregiver.lostaccess.title".localized(),
            message: "role.caregiver.lostaccess.message".localized(),
            primaryAction: okAction
        )
        
        Task {
            await AppRouter.current.windowOverlayUtility.hidePopupView(animated: false)
            await AppRouter.current.windowOverlayUtility.displayPopupView(with: configurationData, animated: true)
        }
    }
}
