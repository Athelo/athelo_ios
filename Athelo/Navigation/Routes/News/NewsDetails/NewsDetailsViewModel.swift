//
//  NewsDetailsViewModel.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 06/07/2022.
//

import Combine
import UIKit

final class NewsDetailsViewModel: BaseViewModel {
    // MARK: - Properties
    @Published private(set) var newsData: NewsData?
    
    private var originalFavoriteState: Bool?
    var shouldSendFavoriteUpdateEvent: Bool {
        guard let newsData = newsData,
              let originalState = originalFavoriteState else {
            return false
        }

        return newsData.isFavourite != originalState
    }
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - Initialization
    override init() {
        super.init()
        
        sink()
    }
    
    // MARK: - Public API
    func assignConfigurationData(_ configurationData: ModelConfigurationData<NewsData>) {
        switch configurationData {
        case .data(let data):
            self.newsData = data
            self.originalFavoriteState = data.isFavourite
        case .id(let id):
            state.send(.loading)
            
            let request = PostDetailsRequest(id: id)
            (AtheloAPI.Posts.details(request: request) as AnyPublisher<NewsData, APIError>)
                .sink { [weak self] result in
                    self?.state.send(result.toViewModelState())
                } receiveValue: { [weak self] value in
                    self?.newsData = value
                    self?.originalFavoriteState = value.isFavourite
                }.store(in: &cancellables)
        }
    }
    
    func switchFavoriteState() {
        guard let newsData = newsData,
              state.value != .loading else {
            return
        }
        
        let newsID = newsData.id
        let shouldAdd = !newsData.isFavourite
        
        let request: AnyPublisher<Void, Error> = {
            if shouldAdd {
                let request = PostAddFavoriteRequest(postID: newsID)
                return Publishers.NetworkingPublishers.NeverWrappingPublisher(request: Deferred { AtheloAPI.Posts.addFavorite(request: request) })
                    .mapError({ $0 as Error })
                    .eraseToAnyPublisher()
            } else {
                let request = PostRemoveFavoriteRequest(postID: newsID)
                return Publishers.NetworkingPublishers.NeverWrappingPublisher(request: Deferred { AtheloAPI.Posts.removeFavorite(request: request) })
                    .mapError({ $0 as Error })
                    .eraseToAnyPublisher()
            }
        }()
        
        state.send(.loading)
        
        request
            .flatMap({ _ -> AnyPublisher<NewsData, Error> in
                let request = PostDetailsRequest(id: newsID)
                return (AtheloAPI.Posts.details(request: request) as AnyPublisher<NewsData, APIError>)
                    .mapError({ $0 as Error })
                    .eraseToAnyPublisher()
            })
            .sink { [weak self] result in
                self?.state.send(result.toViewModelState())
            } receiveValue: { [weak self] value in
                self?.newsData = value
                
                DispatchQueue.main.async {
                    LocalNotificationData.postNotification(.newsFavoriteStateUpdated, parameters: [.newsData: value])
                }
            }.store(in: &cancellables)
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoLocalNotifications()
    }
    
    private func sinkIntoLocalNotifications() {
        LocalNotificationData.publisher(for: .newsFavoriteStateUpdated)
            .compactMap({ $0?.value(for: .newsData) as? NewsData })
            .filter({ [weak self] value in
                value != self?.newsData
            })
            .sink { [weak self] in
                self?.newsData = $0
            }.store(in: &cancellables)
    }
}
