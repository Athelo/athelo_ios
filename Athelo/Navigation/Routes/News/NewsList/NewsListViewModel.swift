//
//  NewsListViewModel.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 04/07/2022.
//

import Combine
import UIKit

final class NewsListViewModel: BaseViewModel {
    enum Filter: Int, CaseIterable {
        case allNews
        case favoriteNews
        
        var name: String {
            switch self {
            case .allNews:
                return "news.list.tab.all".localized()
            case .favoriteNews:
                return "news.list.tab.favorites".localized()
            }
        }
    }
    
    // MARK: - Properties
    private lazy var allNewsFetcher = PaginatedDataUtility<NewsData> { [weak self] query in
        let request = PostListRequest(query: query, categoryIDs: self?.selectedTopics.value.map({ $0.id }) ?? [])
        return (AtheloAPI.Posts.list(request: request) as AnyPublisher<ListResponseData<NewsData>, APIError>)
            .mapError({ $0 as Error })
            .eraseToAnyPublisher()
    }
    
    private lazy var favoriteNewsFetcher = PaginatedDataUtility<NewsData> { [weak self] query in
        let request = PostListRequest(query: query, categoryIDs: self?.selectedTopics.value.map({ $0.id }) ?? [], favorite: true)
        return (AtheloAPI.Posts.list(request: request) as AnyPublisher<ListResponseData<NewsData>, APIError>)
            .mapError({ $0 as Error })
            .eraseToAnyPublisher()
    }
    
    var didReceiveNews: (([ContentfulNewsData]) -> Void)? = nil
    
    @Published private(set) var itemSnapshot: NSDiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier>?

    private var cachedFilters: [FilterData]?
    
    private let query = CurrentValueSubject<String?, Never>(nil)
    private let selectedTopics = CurrentValueSubject<[NewsTopicData], Never>([])
    
    private let filterSubject = CurrentValueSubject<Filter, Never>(.allNews)
    var filterPublisher: AnyPublisher<Filter, Never> {
        filterSubject
            .eraseToAnyPublisher()
    }
    var filter: Filter {
        filterSubject.value
    }
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - Initialization
    override init() {
        super.init()
        
        sink()
    }
    
    // MARK: - Public API
    func assignQuery(_ query: String?) {
        guard state.value != .loading else {
            return
        }
        
        state.send(.loading)
        
        self.query.send(query)
    }
    
    func assignTopics(_ topics: [Filterable]) {
        selectedTopics.send(topics.compactMap({ $0 as? NewsTopicData }))
    }
    
    func decorationItem(for identifier: ItemIdentifier) -> ArticleCellDecorationData? {
        switch identifier {
        case .newsItem(let id):
            switch filter {
            case .allNews:
                return allNewsFetcher.items?.first(where: { $0.id == id })
            case .favoriteNews:
                return favoriteNewsFetcher.items?.first(where: { $0.id == id })
            }
        }
    }
    
    func decorationItem(at indexPath: IndexPath) -> ArticleCellDecorationData? {
        item(at: indexPath)
    }
    
    func filterData() -> FiltersViewConfigurationData {
        let contentTitle = "news.filter.select".localized()
        
        if var filters = cachedFilters, !filters.isEmpty {
            filters = filters.map({ filter in
                let isSelected = selectedTopics.value.first(where: { $0.id == filter.filterable.filterOptionID }) != nil
                return FilterData(filterable: filter.filterable, isSelected: isSelected)
            })
            
            return .init(originalItems: .array(filters), headerText: contentTitle)
        }
        
        let publisher = ConstantsStore.newsTopicsPublisher()
            .map({ [weak self] value -> [FilterData] in
                value.map({ topic in
                    let isSelected = self?.selectedTopics.value.first(where: { $0.id == topic.id }) != nil
                    return FilterData(filterable: topic, isSelected: isSelected)
                })
            })
            .handleEvents(receiveOutput: { [weak self] in
                self?.cachedFilters = $0
            })
            .eraseToAnyPublisher()
        
        return .init(originalItems: .publisher(publisher), headerText: contentTitle)
    }
    
    func item(at indexPath: IndexPath) -> NewsData? {
        switch filter {
        case .allNews:
            return allNewsFetcher.items?[indexPath.row]
        case .favoriteNews:
            return favoriteNewsFetcher.items?[indexPath.row]
        }
    }
    
    func refresh() {
        guard state.value != .loading else {
            return
        }
        
        state.send(.loading)
        
        switch filter {
        case .allNews:
            getNews()
            allNewsFetcher.refresh()
        case .favoriteNews:
            favoriteNewsFetcher.refresh()
        }
    }
    
    func switchFilter(to filter: Filter) {
        guard filter != self.filter else {
            return
        }
        
        self.filterSubject.send(filter)
    }
    
    var newsList: Array<ContentfulNewsData>? = nil
    
    var allNewsList: Array<ContentfulNewsData>? = nil
    
    func getNews() {
        let contentful = ContentfulService()
        contentful.getAllNews(completionBlock: { [weak self] result in
            print(result)
            switch result {
            case .success(let entriesArrayResponse):
                print(entriesArrayResponse)
                self?.newsList = entriesArrayResponse
                self?.allNewsList = entriesArrayResponse
                self?.didReceiveNews?(entriesArrayResponse)
            case .failure(let error):
              print("Oh no something went wrong: \(error)")
            }
        })
    }
    
    func filterFavourite(to filter: Filter) {
        guard allNewsList != nil else {return}
//        newsList = Array(allNewsList![0...1])
    }
    
    func getDecorationItem(at: IndexPath) -> ArticleCellDecorationData? {
        self.newsList?[at.row]
    }
    
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoLocalNotifications()
        sinkIntoOwnSubjects()
    }
    
    private func sinkIntoLocalNotifications() {
        LocalNotificationData.publisher(for: .newsFavoriteStateUpdated)
            .compactMap({ $0?.value(for: .newsData) as? NewsData })
            .sink { [weak self] in
                self?.allNewsFetcher.updateIfExisting($0)
                self?.favoriteNewsFetcher.refresh()
            }.store(in: &cancellables)
    }
    
    private func sinkIntoOwnSubjects() {
        Publishers.CombineLatest3(
            filterSubject,
            allNewsFetcher.itemsPublisher,
            favoriteNewsFetcher.itemsPublisher
        )
        .map({ (filter, allNews, favoriteNews) -> [NewsData]? in
            switch filter {
            case .allNews:
                return allNews
            case .favoriteNews:
                return favoriteNews
            }
        })
        .removeDuplicates()
        .map({ value -> NSDiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier> in
            var snapshot = NSDiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier>()
            
            snapshot.appendSections([.news])
            snapshot.appendItems(value?.map({ .newsItem($0.id) }) ?? [], toSection: .news)
            
            return snapshot
        })
        .sink { [weak self] in
            self?.itemSnapshot = $0
        }.store(in: &cancellables)
        
        allNewsFetcher.itemsPublisher.dropFirst()
            .merge(with: favoriteNewsFetcher.itemsPublisher.dropFirst())
            .sinkDiscardingValue { [weak self] in
                if self?.state.value != .loaded {
                    self?.state.send(.loaded)
                }
            }.store(in: &cancellables)
        
        allNewsFetcher.errorPublisher
            .merge(with: favoriteNewsFetcher.errorPublisher)
            .sink { [weak self] in
                self?.state.send(.error(error: $0))
            }.store(in: &cancellables)
        
        query
            .sink { [weak self] in
                self?.allNewsFetcher.assignQuery($0)
                self?.favoriteNewsFetcher.assignQuery($0)
            }.store(in: &cancellables)
        
        selectedTopics
            .dropFirst()
            .removeDuplicates(by: { prevTopics, currentTopics in
                Set(prevTopics.map({ $0.id })) == Set(currentTopics.map({ $0.id }))
            })
            .sinkDiscardingValue { [weak self] in
                self?.allNewsFetcher.refresh()
                self?.favoriteNewsFetcher.refresh()
            }.store(in: &cancellables)
    }
}

// MARK: - Helper extensions
extension NewsListViewModel {
    enum SectionIdentifier: Hashable {
        case news
    }
    
    enum ItemIdentifier: Hashable {
        case newsItem(Int)
    }
}
