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
    var filteredNewsValues = CurrentValueSubject<[NewsData], Never>([])
    var favoriteNewsValues = CurrentValueSubject<[NewsData], Never>([])
    
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
                return filteredNewsValues.value.first(where: { $0.contentfulData?.id == id })
            case .favoriteNews:
                return favoriteNewsValues.value.first(where: { $0.contentfulData?.id == id })
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
            return filteredNewsValues.value[indexPath.row]
        case .favoriteNews:
            return favoriteNewsValues.value[indexPath.row]
        }
    }
    
    func refresh() {
        guard state.value != .loading else {
            return
        }
        getNews()
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
                self?.filteredNewsValues.send(self?.allNewsDataList ?? [])
                self?.getFavouritesList(callback: { _ in })
                self?.state.send(.loaded)
            case .failure(let error):
                self?.state.send(.error(error: error))
            }
        })
    }
    
    func getFavouritesList(callback: (([NewsData])  -> Void)) {
        // TODO: API Call
        let favoriteNewsDataList = self.allNewsDataList.enumerated().filter { (index, _) in index % 2 == 0}.map( {$0.element} )
        
        self.favoriteNewsValues.send(favoriteNewsDataList)
        callback(favoriteNewsDataList)
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkSearch()
        sinkIntoLocalNotifications()
    }
    
    private func sinkSearch() {
        query.sink { [weak self] in
            guard let query = $0 else {
                self?.filteredNewsValues.send(self?.allNewsDataList ?? [])
                self?.getFavouritesList(callback: {_ in })
                return
            }
            self?.filteredNewsValues.send(self?.searchNews(query, list: self?.allNewsDataList) ?? [])
            self?.getFavouritesList(callback: {value in
                self?.favoriteNewsValues.send(self?.searchNews(query, list: value) ?? [])
            })
            self?.state.send(.loaded)
        }.store(in: &cancellables)
        
        Publishers.CombineLatest3(
            filterSubject,
            filteredNewsValues,
            favoriteNewsValues
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
            snapshot.appendItems(value?.map({ value in .newsItem(value.contentfulData?.id ?? "")}) ?? [], toSection: .news)
            
            return snapshot
        })
        .sink { [weak self] in
            self?.state.send(.loaded)
            self?.itemSnapshot = $0
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
    
    func searchNews(_ query: String?, list: [NewsData]?) -> [NewsData] {
        guard let list = list else {
            return []
        }
        guard let searchValue = query, !searchValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return list
        }
        
        return list.filter { $0.title?.localizedCaseInsensitiveContains(searchValue) ?? false}
    }
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
