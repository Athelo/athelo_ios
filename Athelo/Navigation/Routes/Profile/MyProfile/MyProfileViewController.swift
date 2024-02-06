//
//  MyProfileViewController.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 13/06/2022.
//

import Combine
import UIKit

final class MyProfileViewController: BaseViewController {
    // MARK: - Outlets
    @IBOutlet private weak var collectionViewContent: UICollectionView!
    
    // MARK: - Properties
    private let viewModel = MyProfileViewModel()
    private var router: MyProfileRouter?
    
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
    }
    
    private func configureContentCollectionView() {
        collectionViewContent.register(MyProfileCollectionViewCell.self)
        collectionViewContent.register(TileCollectionViewCell.self)
        
        collectionViewContent.registerSupplementaryView(SectionTitleCollectionReusableView.self)
        
        collectionViewContent.collectionViewLayout = contentLayout
        collectionViewContent.dataSource = contentDataSource
        collectionViewContent.delegate = self
    }
    
    private func configureOwnView() {
        title = "navigation.password.myprofile".localized()
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
                self?.contentDataSource.apply($0)
            }.store(in: &cancellables)
        
        viewModel.state
            .filter({ $0 == .loaded })
            .filter({ _ in IdentityUtility.userData == nil })
            .first()
            .receive(on: DispatchQueue.main)
            .sinkDiscardingValue {
                AppRouter.current.exchangeRoot(.auth)
            }.store(in: &cancellables)
    }
    
    // MARK: - Updates
    private func createContentCollectionViewDataSource() -> UICollectionViewDiffableDataSource<MyProfileViewModel.SectionIdentifier, MyProfileViewModel.ItemIdentifier> {
        let dataSource = UICollectionViewDiffableDataSource<MyProfileViewModel.SectionIdentifier, MyProfileViewModel.ItemIdentifier>(collectionView: collectionViewContent) { [weak self] collectionView, indexPath, itemIdentifier in
            guard let section = self?.viewModel.section(at: indexPath.section) else {
                fatalError("Cannot generate decoration data at \(indexPath) - unknown section.")
            }
            
            switch section {
            case .profileDetails:
                let cell = collectionView.dequeueReusableCell(withClass: MyProfileCollectionViewCell.self, for: indexPath)
                
                if let self = self {
                    cell.assignDelegate(self)
                }
                
                if var profileData = self?.viewModel.userProfileData() {
                    profileData.cancerStatus = self?.viewModel.cancerStatus
                    cell.configure(profileData, indexPath: indexPath)
                }
                
                return cell
            case .health, .roles, .other:
                let cell = collectionView.dequeueReusableCell(withClass: TileCollectionViewCell.self, for: indexPath)
                
                if let tileData = self?.viewModel.tile(at: indexPath) {
                    cell.configure(tileData, indexPath: indexPath)
                }
                
                return cell
            }
        }
        
        dataSource.supplementaryViewProvider = { [weak self] collectionView, identifier, indexPath in
            guard identifier == SectionTitleCollectionReusableView.identifier else {
                fatalError("Unknown supplementary view identifier of \(identifier).")
            }
            
            let header = collectionView.dequeueReusableSupplementaryView(ofClass: SectionTitleCollectionReusableView.self, for: indexPath)
            
            if let headerData = self?.viewModel.headerSupplementaryData(at: indexPath.section) {
                header.configure(headerData, indexPath: indexPath)
            }
            
            return header
        }
        
        return dataSource
    }
    
    private func createContentCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak viewModel = viewModel] sectionIndex, environments in
            guard let sectionType = viewModel?.section(at: sectionIndex) else {
                fatalError("Unknown section type.")
            }
            
            switch sectionType {
            case .profileDetails:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(120.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(1.0))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = .init(top: 24.0, leading: 16.0, bottom: 24.0, trailing: 16.0)
                
                return section
            case .health, .roles, .other:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(72.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(1.0))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = .init(top: 0.0, leading: 16.0, bottom: 24.0, trailing: 16.0)
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
}

// MARK: - Protocol conformance
// MARK: MyProfileCollectionViewCell
extension MyProfileViewController: MyProfileCollectionViewCellDelegate {
    func myProfileCollectionViewCellAsksToEditProfile(_ cell: MyProfileCollectionViewCell) {
        router?.navigateToEditProfileForm()
    }
}

// MARK: Navigable
extension MyProfileViewController: Navigable {
    static var storyboardScene: StoryboardScene{
        .profile
    }
}

// MARK: Routable
extension MyProfileViewController: Routable {
    typealias RouterType = MyProfileRouter
    
    func assignRouter(_ router: MyProfileRouter) {
        self.router = router
    }
}

// MARK: UICollectionViewDelegate
extension MyProfileViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let item = viewModel.item(at: indexPath) {
            switch item {
            case .actAs:
                router?.navigateToRoleSelection()
            case .changePassword:
                router?.navigateToChangePasswordForm()
            case .deleteAnAccount:
                let deleteAction = PopupActionData(title: "action.delete".localized(), customStyle: .destructive) { [weak self] in
                    self?.viewModel.deleteAccount()
                }
                let cancelAction = PopupActionData(title: "action.cancel".localized())
                let popupData = PopupConfigurationData(template: .deleteAccount, primaryAction: deleteAction, secondaryAction: cancelAction)
                
                AppRouter.current.windowOverlayUtility.displayPopupView(with: popupData)
            case .logOut:
                let logOutAction = PopupActionData(title: "action.logout".localized()) { [weak self] in
                    self?.viewModel.logOut()
                    AppRouter.current.exchangeRoot(.auth)
                }
                let cancelAction = PopupActionData(title: "action.cancel".localized())
                let popupData = PopupConfigurationData(template: .logOut, primaryAction: logOutAction, secondaryAction: cancelAction)
                
                AppRouter.current.windowOverlayUtility.displayPopupView(with: popupData)
            case .myDevice:
                router?.navigateToDeviceDetails()
            case .mySymptoms:
                router?.navigateToSymptomList()

            case .trackMyWellbeing:
                router?.navigateToSymptomRegistration()
            }
        } else {
            guard viewModel.section(at: indexPath.section) != .profileDetails else {
                return
            }
            
            displayMessage("message.comingsoon".localized())
        }
    }
}
