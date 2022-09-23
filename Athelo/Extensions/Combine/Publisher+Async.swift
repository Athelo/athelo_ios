//
//  Publisher+Async.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 19/07/2022.
//

import Combine
import Foundation

enum AsyncPublisherTaskError: Error {
    case noValueAvailable
}

extension Publisher {
    func asAsyncTask() async throws -> Output {
        var cancellable: AnyCancellable?
        
        return try await withCheckedThrowingContinuation { continuation in
            var expectedValue: Output?
            
            cancellable = withExtendedLifetime(cancellable, {
                sink { result in
                    cancellable?.cancel()
                    cancellable = nil
                    
                    switch result {
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    case .finished:
                        guard let value = expectedValue else {
                            continuation.resume(throwing: AsyncPublisherTaskError.noValueAvailable)
                            return
                        }
                        
                        continuation.resume(returning: value)
                    }
                } receiveValue: { value in
                    expectedValue = value
                }
            })
        }
    }
    
    func asAsyncTask() async throws where Output == Never {
        var cancellable: AnyCancellable?
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            cancellable = withExtendedLifetime(cancellable, {
                sink { result in
                    cancellable?.cancel()
                    cancellable = nil
                    
                    switch result {
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    case .finished:
                        continuation.resume()
                    }
                }
            })
        }
    }
}
