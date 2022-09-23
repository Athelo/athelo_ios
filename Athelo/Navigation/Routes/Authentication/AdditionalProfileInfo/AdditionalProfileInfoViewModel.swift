//
//  AdditionalProfileInfoViewModel.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 03/06/2022.
//

import Combine
import UIKit

final class AdditionalProfileInfoViewModel: BaseViewModel {
    // MARK: - Properties
    private let name = CurrentValueSubject<String?, Never>(nil)
    private let userType = CurrentValueSubject<UserTypeConstant?, Never>(nil)
    var selectedUserType: UserTypeConstant? {
        userType.value
    }
    
    @Published private(set) var isValid: Bool = false
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - Initialization
    override init() {
        super.init()
        
        sink()
    }
    
    // MARK: - Public API
    func assignName(_ name: String?) {
        self.name.send(name)
    }
    
    func assignUserType(_ userType: UserTypeConstant) {
        self.userType.send(userType)
    }
    
    func sendRequest() {
        guard state.value != .loading, isValid,
              let name = name.value,
              let userType = userType.value else {
            return
        }
        
        state.send(.loading)
        
        IdentityUtility.createAccount(name: name, userType: userType)
            .sink { [weak self] in
                self?.state.send($0.toViewModelState())
            } receiveValue: { _ in
                /* ... */
            }.store(in: &cancellables)
    }
    
    func userTypesPublisher() -> AnyPublisher<[ListInputCellItemData], Error> {
        Deferred {
            ConstantsStore.constantsPublisher()
                .map({ $0.userTypes })
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoOwnSubjects()
    }
    
    private func sinkIntoOwnSubjects() {
        let validNamePublisher = name.map({ $0?.isEmpty == false }).eraseToAnyPublisher()
        let validUserTypePublisher = userType.map({ $0 != nil }).eraseToAnyPublisher()
        
        validNamePublisher
            .combineLatest(validUserTypePublisher)
            .map({ $0 && $1 })
            .removeDuplicates()
            .sink { [weak self] in
                self?.isValid = $0
            }.store(in: &cancellables)
    }
}
