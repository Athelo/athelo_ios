//
//  MenuViewController.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 09/06/2022.
//

import Combine
import CombineCocoa
import UIKit

final class MenuViewController: BaseViewController {
    // MARK: - Constants
    private enum Constants {
        static let menuWidth: CGFloat = 277.0
        static let visiblityAnimationTime: TimeInterval = 0.3
    }
    
    // MARK: - Outlets
    @IBOutlet private weak var buttonHide: UIButton!
    @IBOutlet private weak var imageViewUserAvatar: UIImageView!
    @IBOutlet private weak var labelUserName: UILabel!
    @IBOutlet private weak var tableViewOptions: UITableView!
    @IBOutlet private weak var viewBackground: UIView!
    @IBOutlet private weak var viewContentContainer: UIView!
    
    // MARK: - Constraints
    @IBOutlet private weak var constraintViewContentContainerLeading: NSLayoutConstraint!
    
    // MARK: - Properties
    private let viewModel = MenuViewModel()
    
    private lazy var optionsDataSource = {
        UITableViewDiffableDataSource<MenuViewModel.SectionIdentifier, MenuViewModel.ItemIdentifier>(tableView: tableViewOptions) { [weak self] tableView, indexPath, itemIdentifier in
            let cell = tableView.dequeueReusableCell(withClass: MenuTableViewCell.self, for: indexPath)
            
            if let option = self?.viewModel.option(at: indexPath) {
                cell.configure(option, indexPath: indexPath)
            }
            
            return cell
        }
    }()
    
    private let selectedOptionSubject = PassthroughSubject<MenuOption, Never>()
    var selectedOptionPublisher: AnyPublisher<MenuOption, Never> {
        selectedOptionSubject
            .eraseToAnyPublisher()
    }
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        sink()
    }
    
    // MARK: - Public API
    func hide(animated: Bool = true) {
        let animationTime = animated ? Constants.visiblityAnimationTime : 0.0
        UIView.animate(withDuration: animationTime, delay: 0.0, options: [.beginFromCurrentState, .curveEaseIn]) { [weak self] in
            self?.constraintViewContentContainerLeading.constant = -Constants.menuWidth
            self?.viewBackground.alpha = 0.0
            
            self?.view.layoutIfNeeded()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + animationTime) { [weak self] in
            self?.view.isHidden = true
        }
    }
    
    func reveal(animated: Bool = true) {
        let animationTime = animated ? Constants.visiblityAnimationTime : 0.0
        UIView.animate(withDuration: animationTime, delay: 0.0, options: [.beginFromCurrentState, .curveEaseOut]) { [weak self] in
            self?.constraintViewContentContainerLeading.constant = 0.0
            self?.viewBackground.alpha = 0.36
            
            self?.view.layoutIfNeeded()
        }
        
        view.isHidden = false
    }
    
    // MARK: - Configuration
    private func configure() {
        configureBackgroundView()
        configureHideButton()
        configureOptionsTableView()
        configureOwnView()
    }
    
    private func configureBackgroundView() {
        weak var weakSelf = self
        let tapGestureRecognizer = UITapGestureRecognizer(target: weakSelf, action: #selector(handleBackgroundViewTap(_:)))
        
        viewBackground.isUserInteractionEnabled = true
        viewBackground.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func configureHideButton() {
        buttonHide.setImage(buttonHide.image(for: .normal)?.withRenderingMode(.alwaysTemplate), for: .normal)
    }
    
    private func configureOptionsTableView() {
        tableViewOptions.register(MenuTableViewCell.self)
        
        tableViewOptions.contentInset = UIEdgeInsets(vertical: 32.0)
        
        tableViewOptions.dataSource = optionsDataSource
    }
    
    private func configureOwnView() {
        view.backgroundColor = .clear
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoOptionsTableView()
        sinkIntoViewModel()
    }
    
    private func sinkIntoOptionsTableView() {
        tableViewOptions.didSelectRowPublisher
            .compactMap({ [weak self] in
                self?.viewModel.option(at: $0)
            })
            .subscribe(selectedOptionSubject)
            .store(in: &cancellables)
    }
    
    private func sinkIntoViewModel() {
        viewModel.$listSnapshot
            .compactMap({ $0 })
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak dataSource = optionsDataSource] in
                dataSource?.apply($0)
            })
            .store(in: &cancellables)
            
        viewModel.$userAvatar
            .compactMap({ $0 })
            .receive(on: DispatchQueue.main)
            .sink { [weak imageView = imageViewUserAvatar] in
                imageView?.displayLoadableImage($0)
            }.store(in: &cancellables)
        
        viewModel.$userName
            .compactMap({ $0 })
            .receive(on: DispatchQueue.main)
            .assign(to: \.text, on: labelUserName)
            .store(in: &cancellables)
    }
    
    // MARK: - Actions
    @IBAction private func handleBackgroundViewTap(_ sender: Any?) {
        guard let gestureRecognizer = sender as? UITapGestureRecognizer,
              gestureRecognizer.view === viewBackground else {
            return
        }
        
        hide()
    }
    
    @IBAction private func closeButtonTapped(_ sender: Any) {
        guard (sender as? UIView) === buttonHide else {
            return
        }
        
        hide()
    }
}

// MARK: - Protocol conformance
// MARK: Navigable
extension MenuViewController: Navigable {
    static var storyboardScene: StoryboardScene {
        .menu
    }
}
