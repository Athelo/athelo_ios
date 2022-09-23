//
//  CommunitiesListViewController.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 30/06/2022.
//

import Combine
import UIKit

final class CommunitiesListViewController: BaseViewController {
    // MARK: - Outlets
    @IBOutlet private weak var collectionViewCommunities: UICollectionView!
    
    // MARK: - Properties
    private let viewModel = CommunitiesListViewModel()
    private var router: CommunitiesListRouter?
    
    private lazy var communitiesDataSource = createCommunitiesCollectionViewDataSource()
    private lazy var communitiesLayout = createCommunitiesCollectionViewLayout()
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        sink()
        
        viewModel.refresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ChatUtility.listenToSystemMessages()
        viewModel.enableLiveUpdates()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        viewModel.disableLiveUpdates()
    }
    
    // MARK: - Configuration
    private func configure() {
        configureCommunitiesCollectionView()
        configureOwnView()
    }
    
    private func configureCommunitiesCollectionView() {
        collectionViewCommunities.addStyledRefreshControl()
        
        collectionViewCommunities.register(ChatRoomCollectionViewCell.self)
        collectionViewCommunities.register(CommunitiesListHeadingCollectionViewCell.self)
        collectionViewCommunities.register(LoadMoreCollectionViewCell.self)
        
        collectionViewCommunities.registerSupplementaryView(SectionTitleCollectionReusableView.self)
        
        collectionViewCommunities.collectionViewLayout = communitiesLayout
        collectionViewCommunities.dataSource = communitiesDataSource
        collectionViewCommunities.delegate = self
    }
    
    private func configureOwnView() {
        navigationItem.displayAppLogo()
        
        cancellables.append(navigationItem.displayUserAvatar(with: router))
        
        // It seems that viewDidLoad can be called before parent nav stack is swapped. Quite a curious behavior - hence, delay is needed.
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            
            if self.navigationController?.viewControllers.first == self {
                AppRouter.current.appendMenuNavigationItem(to: self)
            }
        }
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoCommunitiesCollectionView()
        sinkIntoRouter()
        sinkIntoViewModel()
    }
    
    private func sinkIntoCommunitiesCollectionView() {
        collectionViewCommunities.refreshControl?.controlEventPublisher(for: .valueChanged)
            .sinkDiscardingValue { [weak self] in
                if self?.viewModel.state.value == .loading {
                    self?.collectionViewCommunities.refreshControl?.endRefreshing()
                } else {
                    self?.viewModel.refresh()
                }
            }.store(in: &cancellables)
    }
    
    private func sinkIntoRouter() {
        router?.communityUpdateEventsSubject
            .compactMap({ $0.updatedChatRoomData })
            .sink(receiveValue: { [weak self] in
                self?.viewModel.updateChatRoom($0)
            }).store(in: &cancellables)
    }
    
    private func sinkIntoViewModel() {
        bindToViewModel(viewModel, cancellables: &cancellables)
        
        viewModel.state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                switch $0 {
                case .error, .loaded:
                    self?.collectionViewCommunities.refreshControl?.endRefreshing()
                case .loading, .initial:
                    break
                }
            }.store(in: &cancellables)
        
        viewModel.dataSnapshotPublisher
            .compactMap({ $0 })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.communitiesDataSource.apply($0)
            }.store(in: &cancellables)
    }
    
    // MARK: - Updates
    private func createCommunitiesCollectionViewDataSource() -> UICollectionViewDiffableDataSource<CommunitiesListViewModel.SectionIdentifier, CommunitiesListViewModel.ItemIdentifier> {
        let dataSource = UICollectionViewDiffableDataSource<CommunitiesListViewModel.SectionIdentifier, CommunitiesListViewModel.ItemIdentifier>(collectionView: collectionViewCommunities) { [weak self] collectionView, indexPath, itemIdentifier in
            guard let section = self?.viewModel.section(at: indexPath.section) else {
                fatalError("Unknown section type.")
            }
            
            switch section {
            case .leading:
                return collectionView.dequeueReusableCell(withClass: CommunitiesListHeadingCollectionViewCell.self, for: indexPath)
            case .loadMore:
                return collectionView.dequeueReusableCell(withClass: LoadMoreCollectionViewCell.self, for: indexPath)
            case .myCommunities, .otherCommunities:
                let cell = collectionView.dequeueReusableCell(withClass: ChatRoomCollectionViewCell.self, for: indexPath)
                
                if let self = self {
                    cell.assignDelegate(self)
                }
                
                if let data = self?.viewModel.item(at: indexPath) {
                    cell.configure(data, indexPath: indexPath)
                }
                
                return cell
            }
        }
        
        dataSource.supplementaryViewProvider = { [weak self] collectionView, identifier, indexPath in
            guard let sectionTitle = self?.viewModel.sectionTitle(at: indexPath.section) else {
                return nil
            }
            
            let header = collectionView.dequeueReusableSupplementaryView(ofClass: SectionTitleCollectionReusableView.self, for: indexPath)
            
            header.configure(.init(title: sectionTitle, font: .withStyle(.headline20)), indexPath: indexPath)
            
            return header
        }
        
        return dataSource
    }
    
    private func createCommunitiesCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak viewModel = viewModel] sectionIndex, environment in
            guard let sectionType = viewModel?.section(at: sectionIndex) else {
                fatalError("Unknown section type.")
            }
            
            switch sectionType {
            case .leading:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(80.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(1.0))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = .init(top: 24.0, leading: 16.0, bottom: 16.0, trailing: 16.0)
                
                return section
            case .loadMore:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(40.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(40.0))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = .init(top: 0.0, leading: 0.0, bottom: 16.0, trailing: 0.0)
                
                return section
            case .myCommunities, .otherCommunities:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(153.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(1.0))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = .init(top: 0.0, leading: 16.0, bottom: 24.0, trailing: 16.0)
                section.interGroupSpacing = 24.0

                let headerItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(1.0))
                let headerItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerItemSize, elementKind: SectionTitleCollectionReusableView.identifier, alignment: .top, absoluteOffset: .init(x: 0.0, y: -16.0))
                
                section.boundarySupplementaryItems = [headerItem]
                
                return section
            }
        }
        
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.scrollDirection = .vertical
        
        layout.configuration = configuration
        
        return layout
    }
}

// MARK: - Protocol conformance
// MARK: ChatRoomCollectionViewCellDelegate
extension CommunitiesListViewController: ChatRoomCollectionViewCellDelegate {
    func chatRoomCollectionViewCell(_ cell: ChatRoomCollectionViewCell, asksToPerformActionForChatRoomWithID chatRoomID: Int) {
        AppRouter.current.windowOverlayUtility.dismissMessage()
        
        guard let item = viewModel.item(for: chatRoomID) else {
            return
        }
        
        router?.navigateToCommunityChat(item)
    }
}

// MARK: Navigable
extension CommunitiesListViewController: Navigable {
    static var storyboardScene: StoryboardScene {
        .community
    }
}

// MARK: Routable
extension CommunitiesListViewController: Routable {
    func assignRouter(_ router: CommunitiesListRouter) {
        self.router = router
    }
}

// MARK: UICollectionViewDelegate
extension CommunitiesListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = viewModel.item(at: indexPath) as? ChatRoomData else {
            return
        }
        
        router?.navigateToCommunityChat(item)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if cell is LoadMoreCollectionViewCell {
            viewModel.loadMore()
        }
    }
}
