//
//  MyDeviceViewModel.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 01/08/2022.
//

import Combine
import UIKit

final class MyDeviceViewModel: BaseViewModel {
    // MARK: - Properties
    private let forceFitbitRemovalSubject = PassthroughSubject<Void, Never>()
    var forceFitbitRemovalPublisher: AnyPublisher<Void, Never> {
        forceFitbitRemovalSubject.eraseToAnyPublisher()
    }
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - Public API
    func disconnectDevice(forced: Bool = false) {
        guard state.value != .loading else {
            return
        }
        
        state.send(.loading)
        
        Task { [weak self] in
            do {
                let profiles = try await Publishers.NetworkingPublishers.ListRepeatingPublisher(initialRequest: Deferred { AtheloAPI.Fitbit.profileList() as AnyPublisher<ListResponseData<FitbitProfileData>, APIError> }).asAsyncTask()
                
                guard !profiles.isEmpty else {
                    self?.state.send(.loaded)
                    self?.message.send(.init(text: "error.nodevicedata".localized(), type: .plain))
                    
                    return
                }
                
                for profileID in profiles.map({ $0.id }) {
                    let request = FitbitDeleteProfileRequest(id: profileID)
                    try await AtheloAPI.Fitbit.deleteProfile(request: request).asAsyncTask()
                }
                
                try await _ = IdentityUtility.refreshUserDetails().asAsyncTask()
                
                self?.state.send(.loaded)
            } catch let error {
                // Error code 331060 means that server was unable to remove Fitbit profile (while possible that Fitbit profile has been invalidated by the user).
                if !forced,
                   case .httpError(_, let errorMessage) = error as? APIError,
                   errorMessage.errorCode == 331060 {
                    self?.forceFitbitRemovalSubject.send()
                }
                
                self?.state.send(.error(error: error))
            }
        }
    }
}
