//
//  ConnectDeviceViewModel.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 05/07/2022.
//

import Combine
import UIKit

final class ConnectDeviceViewModel: BaseViewModel {
    // MARK: - Constants
    enum ConnectionStatus {
        case notEstablished
        case connected
        case connectionFailed
    }
    
    // MARK: - Properties
    @Published private(set) var actionTitle: String?
    @Published private(set) var deviceType: DeviceType?
    @Published private(set) var headerText: String?
    @Published private(set) var status: ConnectionStatus?
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - Initialization
    override init() {
        super.init()
        
        sink()
    }
    
    // MARK: - Public API
    func assignDeviceType(_ deviceType: DeviceType) {
        self.deviceType = deviceType
    }
    
    func checkConnectionStatus() {
        guard let deviceType = deviceType else {
            return
        }

        switch deviceType {
        case .fitbit:
            if state.value != .loading {
                state.send(.loading)
            }
            
            IdentityUtility.refreshUserDetails()
                .sink { [weak self] result in
                    self?.state.send(result.toViewModelState())
                } receiveValue: { [weak self] value in
                    if value.hasFitbitUserProfile == true {
                        self?.message.send(.init(text: "message.devicefound".localized(), type: .success))
                        self?.status = .connected
                    } else {
                        self?.message.send(.init(text: "message.somethingwentwrong".localized(), type: .error))
                        self?.status = .connectionFailed
                    }
                }.store(in: &cancellables)
        case .appleWatch:
            break
        }
    }
    
    func handleDeeplink(_ deeplink: DeeplinkType) -> Bool {
        switch deeplink {
        case .operationFailure:
            status = .connectionFailed
            message.send(.init(text: "message.somethingwentwrong".localized(), type: .error))
            
            return true
        case .operationSuccess:
            checkConnectionStatus()
            
            return true
        }
    }
    
    func fitbitSyncURLPublisher() -> AnyPublisher<URL, Error> {
        AtheloAPI.Fitbit.initializeAccess()
            .handleEvents(receiveCompletion: { [weak self] result in
                if case .failure(let error) = result {
                    self?.state.send(.error(error: error))
                }
            })
            .mapError({ $0 as Error })
            .map({ $0.url })
            .eraseToAnyPublisher()
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoOwnSubjects()
    }
    
    private func sinkIntoOwnSubjects() {
        $deviceType
            .compactMap({ $0 })
            .sink { [weak self] in
                self?.establishInitialDeviceStatus(for: $0)
            }.store(in: &cancellables)
        
        let stateChangePublisher: AnyPublisher<(DeviceType?, ConnectionStatus), Never> =
        $deviceType
            .removeDuplicates()
            .combineLatest(
                $status
                    .compactMap({ $0 })
                    .removeDuplicates()
            )
            .eraseToAnyPublisher()
        
        stateChangePublisher
            .map({ (device, status) -> String in
                switch status {
                case .notEstablished:
                    return "watch.sync.prompt".localized(arguments: [device?.shortName ?? "device.shortname.common".localized()])
                case .connected:
                    return "watch.sync.success".localized(arguments: [device?.shortName ?? "device.shortname.common".localized()])
                case .connectionFailed:
                    return "watch.sync.failure".localized(arguments: [device?.shortName ?? "device.shortname.common".localized()])
                }
            })
            .removeDuplicates()
            .sink { [weak self] in
                self?.headerText = $0
            }.store(in: &cancellables)
        
        stateChangePublisher
            .map({ (device, status) -> String in
                switch status {
                case .notEstablished:
                    return "action.connectdevice".localized(arguments: [device?.shortName ?? "device.shortname.common".localized()])
                case .connected:
                    return "action.gotoactivity".localized()
                case .connectionFailed:
                    return "action.connectdevice.again".localized(arguments: [device?.shortName ?? "device.shortname.common".localized()])
                }
            })
            .removeDuplicates()
            .sink { [weak self] in
                self?.actionTitle = $0
            }.store(in: &cancellables)
    }
    
    // MARK: - Updates
    private func establishInitialDeviceStatus(for deviceType: DeviceType) {
        switch deviceType {
        case .fitbit:
            status = IdentityUtility.userData?.hasFitbitUserProfile == true ? .connected : .notEstablished
        case .appleWatch:
            status = .connectionFailed
        }
    }
}
