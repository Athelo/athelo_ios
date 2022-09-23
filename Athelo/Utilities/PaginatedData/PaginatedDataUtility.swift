//
//  PaginatedDataUtility.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 04/07/2022.
//

import Combine
import Foundation

final class PaginatedDataUtility<T: Decodable & Identifiable> {
    // MARK: - Properties
    private let itemsSubject = CurrentValueSubject<[T]?, Never>(nil)
    var itemsPublisher: AnyPublisher<[T]?, Never> {
        itemsSubject.eraseToAnyPublisher()
    }
    var items: [T]? {
        itemsSubject.value
    }
    
    private let errorSubject = CurrentValueSubject<Error?, Never>(nil)
    var errorPublisher: AnyPublisher<Error, Never> {
        errorSubject
            .compactMap({ $0 })
            .eraseToAnyPublisher()
    }
    
    private let querySubject = CurrentValueSubject<String?, Never>(nil)
    var query: String? {
        querySubject.value
    }
    
    private var lastRefreshTerm: DataRefreshTerm?
    
    private let initialRequestBuilder: (String?) -> AnyPublisher<ListResponseData<T>, Error>
    private var nextPageURL: URL?
    var canLoadMore: Bool {
        nextPageURL != nil
    }
    
    private var cancellables: [AnyCancellable] = []
    private var requestCancellable: AnyCancellable?
    
    // MARK: - Initialization
    init(requestBuilder: @escaping (String?) -> AnyPublisher<ListResponseData<T>, Error>) {
        self.initialRequestBuilder = requestBuilder
        
        sink()
    }
    
    // MARK: - Public API
    func assignQuery(_ query: String?) {
        querySubject.send(query)
    }
    
    func loadMore() {
        guard let nextPageURL = nextPageURL else {
            return
        }

        requestCancellable?.cancel()
        requestCancellable = (AtheloAPI.PageBased.nextPage(nextPageURL: nextPageURL) as AnyPublisher<ListResponseData<T>, APIError>)
            .sink(receiveCompletion: { [weak self] result in
                if case .failure(let error) = result {
                    self?.errorSubject.send(error)
                }
            }, receiveValue: { [weak self] value in
                self?.nextPageURL = value.next
                self?.itemsSubject.send((self?.itemsSubject.value ?? []) + value.results)
            })
            
    }
    
    func refresh() {
        requestCancellable?.cancel()
        requestCancellable = initialRequestBuilder(querySubject.value)
            .sink(receiveCompletion: { [weak self] result in
                if case .failure(let error) = result {
                    self?.errorSubject.send(error)
                }
            }, receiveValue: { [weak self] value in
                self?.nextPageURL = value.next
                self?.itemsSubject.send(value.results)
            })
    }
    
    func updateIfExisting(_ item: T) {
        guard let itemIndex = itemsSubject.value?.firstIndex(where: { $0.id == item.id }) else {
            return
        }
        
        itemsSubject.value?[itemIndex] = item
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoOwnSubjects()
    }
    
    private func sinkIntoOwnSubjects() {
        querySubject
            .dropFirst()
            .removeDuplicates()
            .sinkDiscardingValue { [weak self] in
                self?.refresh()
            }.store(in: &cancellables)
    }
}

// MARK: - Helper extensions
private extension PaginatedDataUtility {
    struct DataRefreshTerm {
        let term: String?
    }
}
