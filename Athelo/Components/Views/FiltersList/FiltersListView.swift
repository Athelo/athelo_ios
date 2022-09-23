//
//  FiltersListView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 07/07/2022.
//

import Combine
import UIKit

struct FiltersViewConfigurationData {
    enum ItemsSource {
        case array([FilterData])
        case publisher(AnyPublisher<[FilterData], Error>)
    }
    
    let originalItems: ItemsSource
    let headerText: String
}

protocol FiltersListViewDelegate: AnyObject {
    func filtersViewUpdatedSelectedFiltersWithIDs(_ filters: [Filterable])
    func filtersViewCancelledOperation()
}

final class FiltersListView: UIView {
    // MARK: - Outlets
    @IBOutlet private weak var labelHeader: UILabel!
    @IBOutlet private weak var loadingView: LoadingView!
    @IBOutlet private weak var stackViewContent: UIStackView!
    @IBOutlet private weak var tableViewFilters: UITableView!
    
    // MARK: - Constraints
    @IBOutlet private weak var constraintTableViewFiltersHeight: NSLayoutConstraint!
    
    // MARK: - Properties
    private var filterData: [FilterData] = []
    
    private weak var delegate: FiltersListViewDelegate?
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - View lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configure()
    }
    
    // MARK: - Public API
    @MainActor func assignConfigurationData(_ configurationData: FiltersViewConfigurationData) {
        labelHeader.text = configurationData.headerText
        
        switch configurationData.originalItems {
        case .array(let items):
            filterData = items
            
            tableViewFilters.reloadData()
            updateTableViewContentSize(animated: false)
        case .publisher(let publisher):
            loadingView.isHidden = false
            
            publisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] result in
                    self?.loadingView.isHidden = true
                } receiveValue: { [weak self] value in
                    self?.filterData = value
                    
                    self?.tableViewFilters.reloadData()
                    self?.updateTableViewContentSize()
                }.store(in: &cancellables)
        }
    }
    
    func assignDelegate(_ delegate: FiltersListViewDelegate) {
        self.delegate = delegate
    }
    
    // MARK: - Configuration
    private func configure() {
        configureFiltersTableView()
    }
    
    private func configureFiltersTableView() {
        tableViewFilters.register(FilterTableViewCell.self)
        
        tableViewFilters.dataSource = self
        tableViewFilters.delegate = self
    }
    
    // MARK: - Updates
    private func updateTableViewContentSize(animated: Bool = true) {
        tableViewFilters.invalidateIntrinsicContentSize()
        
        layoutIfNeeded()
        
        let contentHeight = ceil(tableViewFilters.contentSize.height)
        UIView.animate(withDuration: animated ? 0.2 : 0.0, delay: 0.0, options: [.beginFromCurrentState]) { [weak self] in
            self?.constraintTableViewFiltersHeight.constant = contentHeight
            self?.layoutIfNeeded()
        }
    }
    
    // MARK: - Actions
    @IBAction private func cancelButtonTapped(_ sender: Any) {
        delegate?.filtersViewCancelledOperation()
    }
    
    @IBAction private func searchButtonTapped(_ sender: Any) {
        delegate?.filtersViewUpdatedSelectedFiltersWithIDs(filterData.filter({ $0.isSelected }).map({ $0.filterable }))
    }
}

// MARK: - Protocol conformance
// MARK: UITableViewDataSource
extension FiltersListView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filterData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: FilterTableViewCell.self, for: indexPath)
        
        if let item = filterData[safe: indexPath.row] {
            let decorationData = FilterCellDecorationData(optionName: item.filterable.filterOptionName, isSelected: item.isSelected)
            cell.configure(decorationData, indexPath: indexPath)
        }
        
        return cell
    }
}

// MARK: UITableViewDelegate
extension FiltersListView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = filterData[safe: indexPath.row] else {
            return
        }
        
        let updatedItem = FilterData(filterable: item.filterable, isSelected: !item.isSelected)
        filterData[indexPath.row] = updatedItem
        
        tableView.reloadData()
    }
}
