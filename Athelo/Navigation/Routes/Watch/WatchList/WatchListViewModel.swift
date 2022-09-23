//
//  WatchListViewModel.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 05/07/2022.
//

import Combine
import UIKit

final class WatchListViewModel: BaseViewModel {
    // MARK: - Properties
    let model = WatchListModel(devices: [])
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - Initialization
    override init() {
        super.init()
        
        sink()
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoIdentityUtility()
    }
    
    private func sinkIntoIdentityUtility() {
        IdentityUtility.userDataPublisher
            .compactMap({ $0 })
            .map({ DeviceData.fromIdentityProfile($0) })
            .sink(receiveValue: model.updateEntries(_:))
            .store(in: &cancellables)
    }
}
