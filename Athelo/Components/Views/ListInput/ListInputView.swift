//
//  ListInputView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 06/06/2022.
//

import Combine
import UIKit

final class ListInputView: UIView {
    // MARK: - Outlets
    @IBOutlet private weak var loadingView: LoadingView!
    @IBOutlet private weak var tableViewItems: UITableView!
    @IBOutlet private weak var viewContentContainer: UIView!
    
    // MARK: - Constraints
    @IBOutlet private weak var constraintTableViewItemsHeight: NSLayoutConstraint!
    
    // MARK: - Properties
    private var items: [ListInputCellItemData]?
    
    private let selectedItemIndexPathSubject = CurrentValueSubject<IndexPath?, Never>(nil)
    var selectedItemPublisher: AnyPublisher<ListInputCellItemData, Never> {
        selectedItemIndexPathSubject
            .compactMap({ $0 })
            .compactMap({ [weak self] in
                self?.items?[safe: $0.row]
            })
            .eraseToAnyPublisher()
    }
    
    private var cancellables: [AnyCancellable] = []
    private var optionsCancellable: AnyCancellable?
    
    // MARK: - View lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configure()
        sink()
    }
    
    // MARK: - Public API
    func assignAndFireItemsPublisher(_ optionsPublisher: AnyPublisher<[ListInputCellItemData], Error>, preselecting preselectedItem: ListInputCellItemData? = nil) {
        loadingView.isHidden = false
        
        optionsCancellable?.cancel()
        optionsCancellable = optionsPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] _ in
                self?.loadingView.isHidden = true
            }, receiveValue: { [weak self] value in
                self?.updateItems(value, preselecting: preselectedItem)
            })
    }
    
    func updateItems(_ items: [ListInputCellItemData], preselecting preselectedItem: ListInputCellItemData? = nil) {
        self.items = items
        
        let cellHeight = max(UIFont.withStyle(.textField).lineHeight, UIImage(named: "checkmark")?.size.height ?? 0.0) + 16.0
        constraintTableViewItemsHeight.constant = CGFloat(min(3, items.count)) * cellHeight
        
        tableViewItems?.reloadData()
        
        if let preselectedItemIndex = items.firstIndex(where: { preselectedItem?.listInputItemID == $0.listInputItemID }) {
            tableViewItems?.selectRow(at: IndexPath(row: preselectedItemIndex, section: 0), animated: false, scrollPosition: .none)
        }
        
        if items.count > 3 {
            tableViewItems.flashScrollIndicators()
        }
    }
    
    // MARK: - Configuration
    private func configure() {
        configureContentContainerView()
        configureItemsTableView()
    }
    
    private func configureContentContainerView() {
        viewContentContainer.layer.masksToBounds = true
        viewContentContainer.layer.cornerRadius = 30.0
    }
    
    private func configureItemsTableView() {
        tableViewItems.register(ListInputTableViewCell.self)
        
        tableViewItems.dataSource = self
    }
    
    private func configureLoadingView() {
        loadingView.isHidden = true
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoItemsTableView()
    }
    
    private func sinkIntoItemsTableView() {
        tableViewItems.didSelectRowPublisher
            .map({ Optional($0) })
            .subscribe(selectedItemIndexPathSubject)
            .store(in: &cancellables)
    }
}

// MARK: - Protocol conformance
// MARK: CustomFormTextFieldInputView
extension ListInputView: CustomFormTextFieldInputView {
    var maximumExpectedContainerHeight: CGFloat {
        let cellHeight = max(UIFont.withStyle(.textField).lineHeight, UIImage(named: "checkmark")?.size.height ?? 0.0) + 16.0
        return CGFloat(ceilf(Float(cellHeight) * 3.0))
    }
}

// MARK: UITableViewDataSource
extension ListInputView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: ListInputTableViewCell.self, for: indexPath)
        
        if let item = items?[safe: indexPath.row] {
            cell.configure(item, indexPath: indexPath)
        }
        
        return cell
    }
}
