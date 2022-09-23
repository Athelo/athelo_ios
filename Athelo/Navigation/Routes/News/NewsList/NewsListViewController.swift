//
//  NewsListViewController.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 04/07/2022.
//

import Combine
import CombineCocoa
import UIKit

final class NewsListViewController: KeyboardListeningViewController {
    // MARK: - Outlets
    @IBOutlet private weak var collectionViewNews: UICollectionView!
    @IBOutlet private weak var noContentView: NoContentView!
    @IBOutlet private weak var segementedPickerFavorites: SegmentedPickerView!
    @IBOutlet private weak var textFieldSearch: UITextField!
    @IBOutlet private weak var viewFiltersContainer: UIView!
    
    private weak var filtersView: FiltersListView?
    
    // MARK: - Constraints
    @IBOutlet private weak var constraintTableViewNewsBottom: NSLayoutConstraint!
    
    // MARK: - Properties
    private let viewModel = NewsListViewModel()
    private var router: NewsListRouter?
    
    private lazy var newsDataSource = createNewsCollectionViewDataSource()
    private lazy var newsLayout = createNewsCollectionViewLayout()
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        sink()
    }
    
    // MARK: - Configuration
    private func configure() {
        configureFavoritesSegmentedPicker()
        configureNewsCollectionView()
        configureNoContentView()
        configureOwnView()
    }
    
    private func configureFavoritesSegmentedPicker() {
        segementedPickerFavorites.assignOptions(NewsListViewModel.Filter.allCases.map({ $0.name }), preselecting: viewModel.filter.rawValue)
    }
    
    private func configureNewsCollectionView() {
        collectionViewNews.register(ArticleCollectionViewCell.self)
        
        collectionViewNews.collectionViewLayout = createNewsCollectionViewLayout()
        collectionViewNews.dataSource = createNewsCollectionViewDataSource()
        collectionViewNews.delegate = self
        
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .withStyle(.purple988098)
        
        collectionViewNews.refreshControl = refreshControl
    }
    
    private func configureNoContentView() {
        noContentView.alpha = 0.0
    }
    
    private func configureOwnView() {
        navigationItem.displayAppLogo()
        
        cancellables.append(navigationItem.displayUserAvatar(with: router))
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoFavoritesSegmentedPicker()
        sinkIntoKeyboardChanges()
        sinkIntoNewsCollectionView()
        sinkIntoSearchTextField()
        sinkIntoViewModel()
    }
    
    private func sinkIntoFavoritesSegmentedPicker() {
        segementedPickerFavorites.selectedItemPublisher
            .compactMap({ NewsListViewModel.Filter(rawValue: $0) })
            .sink(receiveValue: viewModel.switchFilter(to:))
            .store(in: &cancellables)
    }
    
    private func sinkIntoKeyboardChanges() {
        keyboardInfoPublisher.sink { [weak self] in
            guard let constraint = self?.constraintTableViewNewsBottom else {
                return
            }
            
            self?.adjustBottomOffset(using: constraint, keyboardChangeData: $0)
        }.store(in: &cancellables)
    }
    
    private func sinkIntoNewsCollectionView() {
        collectionViewNews.refreshControl?.controlEventPublisher(for: .valueChanged)
            .sinkDiscardingValue { [weak self] in
                if self?.viewModel.state.value == .loading {
                    self?.collectionViewNews.refreshControl?.endRefreshing()
                } else {
                    self?.viewModel.refresh()
                }
            }.store(in: &cancellables)
    }
    
    private func sinkIntoSearchTextField() {
        textFieldSearch.returnPublisher
            .map({ [weak self] _ in
                self?.textFieldSearch.text
            })
            .removeDuplicates()
            .sink { [weak self] in
                self?.viewModel.assignQuery($0)
                self?.textFieldSearch.resignFirstResponder()
            }.store(in: &cancellables)
        
        textFieldSearch.textPublisher
            .sinkDiscardingValue { [weak self] in
                self?.updateSearchTextFieldTextColor()
            }.store(in: &cancellables)
    }
    
    private func sinkIntoViewModel() {
        bindToViewModel(viewModel, cancellables: &cancellables)
        
        viewModel.$itemSnapshot
            .compactMap({ $0 })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.newsDataSource.apply($0)
            }.store(in: &cancellables)
        
        viewModel.state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                switch $0 {
                case .error, .loaded:
                    self?.collectionViewNews.refreshControl?.endRefreshing()
                case .loading, .initial:
                    break
                }
            }.store(in: &cancellables)
        
        viewModel.state
            .map({ $0 == .loaded })
            .combineLatest(
                viewModel.$itemSnapshot
                    .map({ $0?.numberOfItems ?? 0 })
                    .map({ $0 <= 0 })
            )
            .map({ !($0 && $1) })
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                UIView.animate(withDuration: 0.2, delay: 0.0, options: [.beginFromCurrentState]) {
                    self?.noContentView.alpha = value ? 0.0 : 1.0
                }
            }.store(in: &cancellables)
    }
    
    // MARK: - Updates
    private func createFiltersView() {
        guard filtersView == nil else {
            return
        }
        
        let filtersView = FiltersListView.instantiate()
        
        filtersView.assignDelegate(self)
        
        self.filtersView = filtersView
    }
    
    private func createNewsCollectionViewDataSource() -> UICollectionViewDiffableDataSource<NewsListViewModel.SectionIdentifier, NewsListViewModel.ItemIdentifier> {
        let dataSource = UICollectionViewDiffableDataSource<NewsListViewModel.SectionIdentifier, NewsListViewModel.ItemIdentifier>(collectionView: collectionViewNews) { [weak self] collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .newsItem:
                let cell = collectionView.dequeueReusableCell(withClass: ArticleCollectionViewCell.self, for: indexPath)
                
                if let decorationData = self?.viewModel.decorationItem(for: itemIdentifier) ?? self?.viewModel.decorationItem(at: indexPath) {
                    cell.configure(decorationData, indexPath: indexPath)
                }
                
                return cell
            }
        }
        
        return dataSource
    }
    
    private func createNewsCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { _, _ in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(136.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(1.0))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 24.0
            section.contentInsets = .init(top: 40.0, leading: 16.0, bottom: 24.0, trailing: 16.0)
            
            return section
        }
        
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.scrollDirection = .vertical
        
        layout.configuration = configuration
        
        return layout
    }
    
    private func displayFiltersView() {
        createFiltersView()
        guard let filtersView = filtersView else {
            return
        }
        
        filtersView.assignConfigurationData(viewModel.filterData())
        AppRouter.current.windowOverlayUtility.displayCustomOverlayView(filtersView) { pinnedView, superview in
            pinnedView.translatesAutoresizingMaskIntoConstraints = false
            superview.addSubview(pinnedView)
            
            NSLayoutConstraint.activate([
                pinnedView.centerXAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.centerXAnchor),
                pinnedView.centerYAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.centerYAnchor),
                pinnedView.widthAnchor.constraint(equalTo: superview.widthAnchor, constant: -32.0),
                pinnedView.topAnchor.constraint(greaterThanOrEqualTo: superview.safeAreaLayoutGuide.topAnchor, constant: 32.0)
            ])
            
            pinnedView.setNeedsLayout()
            pinnedView.layoutIfNeeded()
        }
    }
    
    private func hideFiltersView(passingSelectedFilters filters: [Filterable]? = nil) {
        AppRouter.current.windowOverlayUtility.hideCustomOverlayView(of: FiltersListView.self)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            if let filters = filters {
                self?.viewModel.assignTopics(filters)
            }
        }
    }
    
    private func updateSearchTextFieldTextColor() {
        textFieldSearch.textColor = textFieldSearch.isEditing ? .withStyle(.purple623E61) : .withStyle(.black)
    }
    
    // MARK: - Actions
    @IBAction private func filtersButtonTapped(_ sender: Any) {
        displayFiltersView()
    }
}

// MARK: - Protocol conformance
// MARK: FiltersListViewDelegate
extension NewsListViewController: FiltersListViewDelegate {
    func filtersViewCancelledOperation() {
        hideFiltersView()
    }
    
    func filtersViewUpdatedSelectedFiltersWithIDs(_ filters: [Filterable]) {
        hideFiltersView(passingSelectedFilters: filters)
    }
}

// MARK: Navigable
extension NewsListViewController: Navigable {
    static var storyboardScene: StoryboardScene {
        .news
    }
}

// MARK: Routable
extension NewsListViewController: Routable {
    func assignRouter(_ router: NewsListRouter) {
        self.router = router
    }
}

// MARK: UICollectionViewDelegate
extension NewsListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = viewModel.item(at: indexPath) else {
            return
        }
        
        router?.navigateToNewsDetails(using: .data(item))
    }
}
