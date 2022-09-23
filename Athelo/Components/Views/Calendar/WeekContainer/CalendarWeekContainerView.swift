//
//  CalendarWeekContainerView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 14/07/2022.
//

import SwiftDate
import UIKit

protocol CalendarWeekContainerViewDelegate: AnyObject {
    func calendarWeekContainerView(_ view: CalendarWeekContainerView, selectedDate: Date)
}

final class CalendarWeekContainerView: UIView {
    // MARK: - Outlets
    @IBOutlet private weak var collectionViewDays: UICollectionView!
    
    // MARK: - Properties
    private var configurationData: ConfigurationData? {
        didSet {
            updateSnapshot()
        }
    }
    
    private lazy var daysDataSource: UICollectionViewDiffableDataSource<Int, Date> = createDaysDataSource()
    private lazy var daysLayout: UICollectionViewCompositionalLayout = createDaysLayout()
    
    private weak var delegate: CalendarWeekContainerViewDelegate?
    
    // MARK: - View lifecycle
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupFromNib()
        
        configure()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupFromNib()
        
        configure()
    }
    
    private func setupFromNib() {
        guard let view = Self.nib.instantiate(withOwner: self, options: nil).first as? UIView else {
            fatalError("Error loading \(self) from nib")
        }

        addSubview(view)
        view.frame = self.bounds
        
        superview?.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        superview?.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        superview?.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        superview?.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    private func configure() {
        configureDaysCollectionView()
    }
    
    private func configureDaysCollectionView() {
        collectionViewDays.register(CalendarDayCollectionViewCell.self)
        
        collectionViewDays.collectionViewLayout = daysLayout
        collectionViewDays.dataSource = daysDataSource
        collectionViewDays.delegate = self
    }
    
    // MARK: - Public API
    func assignDelegate(_ delegate: CalendarWeekContainerViewDelegate) {
        self.delegate = delegate
    }
    
    func markSelectedDate(_ date: Date) {
        for cellIndexPath in collectionViewDays.indexPathsForVisibleItems {
            guard let identifier = daysDataSource.itemIdentifier(for: cellIndexPath),
                  let cell = collectionViewDays.cellForItem(at: cellIndexPath) else {
                continue
            }
            
            let shouldSelect = identifier.compare(toDate: date, granularity: .day) == .orderedSame
            if shouldSelect != cell.isSelected {
                cell.isSelected = shouldSelect
            }
        }
    }
    
    // MARK: - Updates
    private func createDaysDataSource() -> UICollectionViewDiffableDataSource<Int, Date> {
        let dataSource = UICollectionViewDiffableDataSource<Int, Date>(collectionView: collectionViewDays) { [weak self] collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueReusableCell(withClass: CalendarDayCollectionViewCell.self, for: indexPath)
            
            var canSelect: Bool = true
            if let minDate = self?.configurationData?.minDate, minDate.compare(toDate: itemIdentifier, granularity: .day) == .orderedAscending {
                canSelect = false
            }
            if !canSelect, let maxDate = self?.configurationData?.maxDate, maxDate.compare(toDate: itemIdentifier, granularity: .day) == .orderedDescending {
                canSelect = false
            }
            
            cell.configure(.init(date: itemIdentifier, selectable: canSelect), indexPath: indexPath)
            
            return cell
        }
        
        return dataSource
    }
    
    private func createDaysLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] section, environment in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0 / Double(self?.configurationData?.days.count ?? 1)), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            
            return section
        }
        
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.scrollDirection = .horizontal
        
        layout.configuration = configuration
        
        return layout
    }
    
    private func updateSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, Date>()
        
        snapshot.appendSections([0])
        snapshot.appendItems(configurationData?.days ?? [])
        
        daysDataSource.apply(snapshot, animatingDifferences: false)
    }
}

// MARK: - Protocol conformance
// MARK: Configurable
extension CalendarWeekContainerView: Configurable {
    struct ConfigurationData {
        let days: [Date]
        let minDate: Date?
        let maxDate: Date?
        
        init(days: [Date], minDate: Date? = nil, maxDate: Date? = nil) {
            self.days = days
            self.minDate = minDate
            self.maxDate = maxDate
        }
    }
    
    typealias ConfigurationDataType = ConfigurationData
    
    func assignConfigurationData(_ configurationData: ConfigurationData) {
        self.configurationData = configurationData
    }
}

// MARK: UICollectionViewDelegate
extension CalendarWeekContainerView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let itemIdentifier = daysDataSource.itemIdentifier(for: indexPath) else {
            return
        }
        
        delegate?.calendarWeekContainerView(self, selectedDate: itemIdentifier)
    }
}
