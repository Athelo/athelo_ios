//
//  NetworkUtility.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 31/05/2022.
//

import Combine
import Foundation
import Network

final class NetworkUtility {
    // MARK: - Properties
    private static let networkQueue = DispatchQueue(label: "com.athelo.network.monitor")
    
    static let utility = NetworkUtility()
    private(set) lazy var networkMonitor: NWPathMonitor = {
        let monitor = NWPathMonitor()
        
        let queue = NetworkUtility.networkQueue
        monitor.start(queue: queue)
        
        return monitor
    }()
    
    private let networkAvailableSubject = CurrentValueSubject<Bool, Never>(false)
    var networkAvailablePublisher: AnyPublisher<Bool, Never> {
        networkAvailableSubject
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    var networkAvailable: Bool {
        networkAvailableSubject.value
    }
    
    // MARK: - Initialization / lifecycle
    init() {
        networkMonitor.pathUpdateHandler = { [weak self] in
            self?.networkAvailableSubject.send($0.status == .satisfied)
        }
    }
    
    deinit {
        networkMonitor.cancel()
    }
}
