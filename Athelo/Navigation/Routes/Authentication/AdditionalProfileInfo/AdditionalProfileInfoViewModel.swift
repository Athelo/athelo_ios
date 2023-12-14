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
    
    func sendRequest() {
        guard state.value != .loading, isValid,
              let name = name.value else {
            return
        }
        
        state.send(.loading)
        
        IdentityUtility.createAccount(name: name)
            .sink { [weak self] in
                self?.state.send($0.toViewModelState())
            } receiveValue: { _ in
                /* ... */
            }.store(in: &cancellables)
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoOwnSubjects()
    }
    
    private func sinkIntoOwnSubjects() {
        let validNamePublisher = name.map({ $0?.isEmpty == false }).eraseToAnyPublisher()
        
        validNamePublisher
            .removeDuplicates()
            .sink { [weak self] in
                self?.isValid = $0
            }.store(in: &cancellables)
    }
}
