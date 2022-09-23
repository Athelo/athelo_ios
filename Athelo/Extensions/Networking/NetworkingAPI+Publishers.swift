//
//  File.swift
//  
//
//  Created by Krzysztof Jabłoński on 23/06/2022.
//

import Combine
import Foundation

public extension Publishers {
    enum NetworkingPublishers {
        /* ... */
    }
}

public extension Publishers.NetworkingPublishers {
    struct ListRepeatingPublisher<DataType: Decodable>: Publisher {
        public typealias Output = [DataType]
        public typealias Failure = APIError
        
        private let initialRequest: Deferred<AnyPublisher<ListResponseData<DataType>, APIError>>
        
        public init(initialRequest: Deferred<AnyPublisher<ListResponseData<DataType>, APIError>>) {
            self.initialRequest = initialRequest
        }
        
        public func receive<S>(subscriber: S) where S : Subscriber, APIError == S.Failure, [DataType] == S.Input {
            let subscription = ListRepeatingSubscription(initialRequest: initialRequest, target: subscriber)
            subscriber.receive(subscription: subscription)
        }
    }
    
    private final class ListRepeatingSubscription<DataType: Decodable, Target: Subscriber>: Subscription where Target.Input == [DataType], Target.Failure == APIError {
        private var ongoingRequest: AnyCancellable?
        private var items: [DataType]?
        
        private var initialRequest: Deferred<AnyPublisher<ListResponseData<DataType>, APIError>>?
        private var target: Target?
        
        init(initialRequest: Deferred<AnyPublisher<ListResponseData<DataType>, APIError>>, target: Target) {
            self.initialRequest = initialRequest
            self.target = target
        }
        
        func request(_ demand: Subscribers.Demand) {
            guard ongoingRequest == nil,
                  let request = initialRequest else {
                return
            }
            
            continueFulfillingDemand(with: request.eraseToAnyPublisher())
            initialRequest = nil
        }
        
        func cancel() {
            ongoingRequest?.cancel()
            target = nil
        }
        
        private func continueFulfillingDemand(with request: AnyPublisher<ListResponseData<DataType>, APIError>) {
            ongoingRequest = request
                .sink { [weak self] result in
                    switch result {
                    case .failure:
                        self?.target?.receive(completion: result)
                    case .finished:
                        break
                    }
                } receiveValue: { [weak self] value in
                    guard let self = self else {
                        return
                    }
                    
                    self.items = (self.items ?? []) + value.results
                    
                    if value.next != nil {
                        let request = AtheloAPI.PageBased.nextPage(pageData: value)
                        self.continueFulfillingDemand(with: request)
                    } else {
                        _ = self.target?.receive(self.items ?? [])
                        self.target?.receive(completion: .finished)
                    }
                }
        }
    }
}

public extension Publishers.NetworkingPublishers {
    struct NeverWrappingPublisher: Publisher {
        public typealias Output = Void
        public typealias Failure = APIError

        private let request: Deferred<AnyPublisher<Never, APIError>>

        public init(request: Deferred<AnyPublisher<Never, APIError>>) {
            self.request = request
        }

        public func receive<S>(subscriber: S) where S : Subscriber, APIError == S.Failure, Void == S.Input {
            let subscription = NeverWrappingSubscription(initialRequest: self.request, target: subscriber)
            subscriber.receive(subscription: subscription)
        }
    }

    private final class NeverWrappingSubscription<Target: Subscriber>: Subscription where Target.Input == Void, Target.Failure == APIError {
        private var ongoingRequest: AnyCancellable?

        private var request: Deferred<AnyPublisher<Never, APIError>>?
        private var target: Target?

        init(initialRequest: Deferred<AnyPublisher<Never, APIError>>, target: Target) {
            self.request = initialRequest
            self.target = target
        }

        func request(_ demand: Subscribers.Demand) {
            guard ongoingRequest == nil,
                  let request = request else {
                return
            }

            ongoingRequest = request
                .sink(receiveCompletion: { [weak self] in
                    switch $0 {
                    case .failure(let error):
                        self?.target?.receive(completion: .failure(error))
                    case .finished:
                        _ = self?.target?.receive(())
                        self?.target?.receive(completion: .finished)
                    }
                })
        }

        func cancel() {
            ongoingRequest?.cancel()
            target = nil
        }
    }
}
