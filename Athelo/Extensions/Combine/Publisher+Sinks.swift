//
//  Publisher+Sinks.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 31/05/2022.
//

import Combine
import Foundation

extension Publisher where Failure == Never {
    /// Acts the same way as `sink(receiveValue: )`, but omits parameter (maps any value to Void before calling `sink`).
    func sinkDiscardingValue(_ closure: @escaping () -> Void) -> AnyCancellable {
        sink { _ in
            closure()
        }
    }
}

extension Publisher where Output == Never {
    /// Attaches a subscriber with closure based behavior on completion event.
    ///
    /// - Parameter receiveCompletion: Closure to be called when completion event is received.
    ///
    /// - Returns: A cancellable instance, which you use when you end assignment of the received value. Deallocation of the result will tear down the subscription stream.
    func sink(receiveCompletion: @escaping (Subscribers.Completion<Failure>) -> Void) -> AnyCancellable {
        sink { result in
            receiveCompletion(result)
        } receiveValue: { _ in
            /* ... */
        }
    }
}
