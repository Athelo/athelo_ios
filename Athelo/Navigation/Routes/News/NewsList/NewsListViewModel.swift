//
//  NewsListViewModel.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 04/07/2022.
//

import Combine
import UIKit

final class NewsListViewModel: BaseViewModel {
    
    var allNewsDataList: [NewsData] = [NewsData]()
    var filteredNewsDataList: [NewsData] = [NewsData]()
    var favoriteNewsDataList: [NewsData] = [NewsData]()
    
    @Published private(set) var itemSnapshot: NSDiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier>?
    
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
    
    
    private var cachedFilters: [FilterData]? // TODO: Probably to be removed after Filter icon is removed
    
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
        getNews()
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
                return allNewsDataList.first(where: { $0.contentfulData?.id == id })
            case .favoriteNews:
                return favoriteNewsDataList.first(where: { $0.contentfulData?.id == id })
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
            return allNewsDataList[indexPath.row]
        case .favoriteNews:
            return favoriteNewsDataList[indexPath.row]
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
        case .favoriteNews:
            getNews()
        }
    }
    
    func switchFilter(to filter: Filter) {
        guard filter != self.filter else {
            return
        }
        
        self.filterSubject.send(filter)
    }
    
    
    func getNews() {
        guard state.value != .loading else {
            return
        }
        state.send(.loading)
        
        let contentful = ContentfulService()
        contentful.getAllNews(completionBlock: { [weak self] result in
            switch result {
            case .success(let entriesArrayResponse):
                
                self?.allNewsDataList = entriesArrayResponse.compactMap({NewsData(abc: $0)}) // Convert to [News Data]
                self?.createSnapShot(newsDataList: self?.allNewsDataList)
                self?.state.send(.loaded)
            case .failure(let error):
                self?.state.send(.error(error: error))
            }
        })
    }
    
    func getFavouritesList(callback: (([NewsData])  -> Void)) {
        // TODO: API Call
        self.favoriteNewsDataList = self.allNewsDataList.enumerated().filter { (index, _) in index % 2 == 0}.map( {$0.element} )
        callback(self.favoriteNewsDataList)
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkFilter()
        sinkSearch()
        sinkIntoLocalNotifications()
    }
    
    private func sinkFilter() {
        self.filterSubject.sink { [weak self] value in
            switch value {
            case .allNews:
                self?.createSnapShot(newsDataList: self?.allNewsDataList)
            case .favoriteNews:
                self?.getFavouritesList { list in
                    self?.createSnapShot(newsDataList: list)
                }
            }
        }.store(in: &cancellables)
    }
    
    private func sinkSearch() {
        Publishers.CombineLatest(self.query, self.filterSubject)
            .map({ (searchText, filter) -> [NewsData] in
                switch filter {
                case .allNews:
                    return self.searchNews(searchText, list: self.allNewsDataList)
                case .favoriteNews:
                    return self.searchNews(searchText, list: self.favoriteNewsDataList)
                }
            }).sink { [weak self] list in
                self?.createSnapShot(newsDataList: list)
            }.store(in: &cancellables)
    }
    
    private func sinkIntoLocalNotifications() {
        //        LocalNotificationData.publisher(for: .newsFavoriteStateUpdated)
        //            .compactMap({ $0?.value(for: .newsData) as? NewsData })
        //            .sink { [weak self] in
        ////                self?.allNewsFetcher.updateIfExisting($0)
        ////                self?.favoriteNewsFetcher.refresh()
        //            }.store(in: &cancellables)
    }
    
    func searchNews(_ query: String?, list: [NewsData]) -> [NewsData] {
        guard let searchValue = query, !searchValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return list
        }
        self.filteredNewsDataList = list.filter { $0.title?.localizedCaseInsensitiveContains(searchValue) ?? false}
        return self.filteredNewsDataList
    }
    
    func createSnapShot(newsDataList: [NewsData]?) {
        var snapShot = NSDiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier>() // Create to Snapshot from NewsData
        snapShot.appendSections([.news])
        newsDataList?.forEach { value in
            snapShot.appendItems([.newsItem(value.contentfulData?.id ?? "")] , toSection: .news)
        }
        self.itemSnapshot = snapShot
        state.send(.loaded)
    }
    
    //    private func sinkIntoOwnSubjects() {
    //        Publishers.CombineLatest3(
    //            filterSubject,
    //            allNewsFetcher.itemsPublisher,
    //            favoriteNewsFetcher.itemsPublisher
    //        )
    //        .map({ (filter, allNews, favoriteNews) -> [NewsData]? in
    //            switch filter {
    //            case .allNews:
    //                return allNews
    //            case .favoriteNews:
    //                return favoriteNews
    //            }
    //        })
    //        .removeDuplicates()
    //        .map({ value -> NSDiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier> in
    //            var snapshot = NSDiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier>()
    //
    //            snapshot.appendSections([.news])
    //            snapshot.appendItems(value?.map({ .newsItem($0.id) }) ?? [], toSection: .news)
    //
    //            return snapshot
    //        })
    //        .sink { [weak self] in
    //            self?.itemSnapshot = $0
    //        }.store(in: &cancellables)
    //
    //        allNewsFetcher.itemsPublisher.dropFirst()
    //            .merge(with: favoriteNewsFetcher.itemsPublisher.dropFirst())
    //            .sinkDiscardingValue { [weak self] in
    //                if self?.state.value != .loaded {
    //                    self?.state.send(.loaded)
    //                }
    //            }.store(in: &cancellables)
    //
    //        allNewsFetcher.errorPublisher
    //            .merge(with: favoriteNewsFetcher.errorPublisher)
    //            .sink { [weak self] in
    //                self?.state.send(.error(error: $0))
    //            }.store(in: &cancellables)
    //
    //        query
    //            .sink { [weak self] in
    //                self?.allNewsFetcher.assignQuery($0)
    //                self?.favoriteNewsFetcher.assignQuery($0)
    //            }.store(in: &cancellables)
    //
    //        selectedTopics
    //            .dropFirst()
    //            .removeDuplicates(by: { prevTopics, currentTopics in
    //                Set(prevTopics.map({ $0.id })) == Set(currentTopics.map({ $0.id }))
    //            })
    //            .sinkDiscardingValue { [weak self] in
    //                self?.allNewsFetcher.refresh()
    //                self?.favoriteNewsFetcher.refresh()
    //            }.store(in: &cancellables)
    //    }
}

// MARK: - Helper extensions
extension NewsListViewModel {
    enum SectionIdentifier: Hashable {
        case news
    }
    
    enum ItemIdentifier: Hashable {
        case newsItem(String)
    }
}
