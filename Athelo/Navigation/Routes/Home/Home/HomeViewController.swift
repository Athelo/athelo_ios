//
//  HomeViewController.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 09/06/2022.
//

import Combine
import UIKit

final class HomeViewController: BaseViewController {
    // MARK: - Outlets
    @IBOutlet private weak var collectionViewContent: UICollectionView!
    @IBOutlet private weak var viewSelectedWardContainer: UIView!
    @IBOutlet private weak var viewSelectedWardHolder: UIView!
    
    private var selectedWardView: SelectedWardView?
    
    private var avatarIconImageView: UIImageView? {
        navigationItem.rightBarButtonItem?.customView as? UIImageView
    }
    
    // MARK: - Properties
    private let viewModel = HomeViewModel()
    private var router: HomeRouter?
    
    private lazy var contentDataSource = createContentCollectionViewDataSource()
    private lazy var contentLayout = createContentCollectionViewLayout()
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        sink()
        
        viewModel.refresh()
    }
    
    // MARK: - Configuration
    private func configure() {
        configureContentCollectionView()
        configureOwnView()
        configureSelectedWardContainerView()
    }
    
    private func configureContentCollectionView() {
        collectionViewContent.register(FeelingsCollectionViewCell.self)
        collectionViewContent.register(HeadlineCollectionViewCell.self)
        collectionViewContent.register(PillCollectionViewCell.self)
        collectionViewContent.register(TileCollectionViewCell.self)
        
        collectionViewContent.registerSupplementaryView(SectionTitleCollectionReusableView.self)
        
        collectionViewContent.collectionViewLayout = contentLayout
        collectionViewContent.dataSource = contentDataSource
        collectionViewContent.delegate = self
    }
    
    private func configureOwnView() {
        navigationItem.displayAppLogo()
        
        cancellables.append(navigationItem.displayUserAvatar(with: router))
    }
    
    private func configureSelectedWardContainerView() {
        guard selectedWardView == nil else {
            return
        }
        
        let selectedWardView = SelectedWardView(
            model: viewModel.selectedWardModel,
            onTapAction: {
                AppRouter.current.windowOverlayUtility.displayWardSelectionView()
            }
        )
        
        embedView(selectedWardView, to: viewSelectedWardHolder)
        
        self.selectedWardView = selectedWardView
        
        viewSelectedWardContainer.isHidden = true
        viewSelectedWardContainer.alpha = 0.0
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoViewModel()
    }
    
    private func sinkIntoViewModel() {
        bindToViewModel(viewModel, cancellables: &cancellables)
        
        viewModel.$dataSnapshot
            .compactMap({ $0 })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.contentDataSource.apply($0, animatingDifferences: true)
            }.store(in: &cancellables)
        
        viewModel.$displaysWardSelection
            .map({ !$0 })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                guard let self,
                      self.viewSelectedWardContainer.isHidden != value else {
                    return
                }
                
                UIView.animate(withDuration: 0.2, delay: 0.0, options: [.beginFromCurrentState]) { [weak self] in
                    self?.viewSelectedWardContainer.isHidden = value
                    self?.viewSelectedWardContainer.alpha = value ? 0.0 : 1.0
                }
            }.store(in: &cancellables)
        
        viewModel.$selectedInteractableItem
            .compactMap({ $0 })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.router?.navigateUsingInteractableItem(value)
            }.store(in: &cancellables)
    }
    
    // MARK: - Updates
    private func createContentCollectionViewDataSource() -> UICollectionViewDiffableDataSource<HomeViewModel.SectionIdentifier, HomeViewModel.ItemIdentifier> {
        let dataSource = UICollectionViewDiffableDataSource<HomeViewModel.SectionIdentifier, HomeViewModel.ItemIdentifier>(collectionView: collectionViewContent) { [weak self] collectionView, indexPath, itemIdentifier in
            guard let decorationData = self?.viewModel.decorationData(at: indexPath) else {
                fatalError("Cannot generate decoration data at \(indexPath).")
            }

            if let feelingScale = decorationData as? FeelingScale {
                let cell = collectionView.dequeueReusableCell(withClass: FeelingsCollectionViewCell.self, for: indexPath)
                
                cell.configure(feelingScale, indexPath: indexPath)
                
                return cell
            } else if let headlineData = decorationData as? HeadlineDecorationData {
                let cell = collectionView.dequeueReusableCell(withClass: HeadlineCollectionViewCell.self, for: indexPath)
                
                cell.configure(headlineData, indexPath: indexPath)
                
                return cell
            } else if let pillDecorationData = decorationData as? PillCellDecorationData {
                let cell = collectionView.dequeueReusableCell(withClass: PillCollectionViewCell.self, for: indexPath)
                
                cell.assignWidthBoundary(floor(collectionView.bounds.width - 32.0))
                cell.configure(pillDecorationData, indexPath: indexPath)
                
                return cell
            } else if let titleDecorationData = decorationData as? TileDecorationData {
                let cell = collectionView.dequeueReusableCell(withClass: TileCollectionViewCell.self, for: indexPath)
                
                cell.configure(titleDecorationData, indexPath: indexPath)
                
                return cell
            }
            
            fatalError("Unknown cell decoration data at \(indexPath).")
        }
        
        dataSource.supplementaryViewProvider = { [weak self] collectionView, identifier, indexPath in
            guard identifier == SectionTitleCollectionReusableView.identifier else {
                fatalError("Unknown supplementary view identifier of \(identifier).")
            }
            
            let header = collectionView.dequeueReusableSupplementaryView(ofClass: SectionTitleCollectionReusableView.self, for: indexPath)
            
            if let headerData = self?.viewModel.headerSupplementaryData(at: indexPath) {
                header.configure(headerData, indexPath: indexPath)
                
                if let self {
                    header.assignDelegate(self)
                }
            }
            
            return header
        }
        
        return dataSource
    }
    
    private func createContentCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak viewModel = viewModel] sectionIndex, environment in
            guard let sectionType = viewModel?.section(at: sectionIndex) else {
                fatalError("Unknown section type.")
            }
            
            switch sectionType {
            case .heading:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(1.0))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = .init(top: 24.0, leading: 16.0, bottom: 40.0, trailing: 16.0)
                
                return section
            case .recommendations, .wellBeing:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(72.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(1.0))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = .init(top: 0.0, leading: 16.0, bottom: 32.0, trailing: 16.0)
                section.interGroupSpacing = 16.0
                
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
    
    // MARK: - Actions
    @IBAction private func profileButtonTapped(_ sender: Any?) {
        router?.navigateToUserProfile()
    }
}

// MARK: - Protocol conformance
// MARK: Navigable
extension HomeViewController: Navigable {
    static var storyboardScene: StoryboardScene{
        .home
    }
}

// MARK: Routable
extension HomeViewController: Routable {
    typealias RouterType = HomeRouter
    
    func assignRouter(_ router: HomeRouter) {
        self.router = router
    }
}

// MARK: SectionTitleCollectionReusableViewDelegate
extension HomeViewController: SectionTitleCollectionReusableViewDelegate {
    func sectionTitleCollectionReusableView(_ view: SectionTitleCollectionReusableView, activatedInteractableItem identifier: String) {
        viewModel.checkActionableItemIdentifier(identifier)
    }
}

// MARK: UICollectionViewDelegate
extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let prompt = viewModel.actionPrompt(at: indexPath) else {
            return
        }
        
        router?.navigateUsingPrompt(prompt)
    }
}
