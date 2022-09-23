//
//  AskAtheloViewController.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 22/06/2022.
//

import Combine
import SwiftUI
import UIKit

final class AskAtheloViewController: BaseViewController {
    // MARK: - Outlets
    @IBOutlet private weak var faqItemsContainerView: UIView!
    
    private var expandableEntriesView: AskAtheloView?
    
    // MARK: - Properties
    private let viewModel = AskAtheloViewModel()
    private var router: AskAtheloRouter?
    
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
        configureFAQItemsContainerView()
        configureOwnView()
    }
    
    private func configureFAQItemsContainerView() {
        guard expandableEntriesView == nil else {
            return
        }
        
        let entriesView = AskAtheloView(model: viewModel.itemsModel, sendMessageAction: { [weak self] in
            self?.router?.navigateToFeedback()
        }, onURLTapAction: { [weak self] url in
            self?.router?.displayURL(url)
        })
        
        let entriesViewController = UIHostingController(rootView: entriesView)
        
        entriesViewController.view.translatesAutoresizingMaskIntoConstraints = false
        entriesViewController.view.backgroundColor = .clear
        
        addChild(entriesViewController)
        faqItemsContainerView.addSubview(entriesViewController.view)
        
        NSLayoutConstraint.activate([
            entriesViewController.view.topAnchor.constraint(equalTo: faqItemsContainerView.topAnchor),
            entriesViewController.view.bottomAnchor.constraint(equalTo: faqItemsContainerView.bottomAnchor),
            entriesViewController.view.leadingAnchor.constraint(equalTo: faqItemsContainerView.leadingAnchor),
            entriesViewController.view.trailingAnchor.constraint(equalTo: faqItemsContainerView.trailingAnchor)
        ])
        
        entriesViewController.didMove(toParent: self)
        
        expandableEntriesView = entriesView
    }
    
    private func configureOwnView() {
        title = "navigation.faq".localized()
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoViewModel()
    }
    
    private func sinkIntoViewModel() {
        bindToViewModel(viewModel, cancellables: &cancellables)
    }
}

// MARK: - Protocol conformance
// MARK: Navigable
extension AskAtheloViewController: Navigable {
    static var storyboardScene: StoryboardScene {
        .faq
    }
}

// MARK: Routable
extension AskAtheloViewController: Routable {
    typealias RouterType = AskAtheloRouter
    
    func assignRouter(_ router: AskAtheloRouter) {
        self.router = router
    }
}
