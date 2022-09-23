//
//  IntroViewController.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 31/05/2022.
//

import Combine
import UIKit

final class IntroViewController: BaseViewController {    
    // MARK: - Outlets
    @IBOutlet private weak var imageViewSmallLogo: UIImageView!
    @IBOutlet private weak var introWomenView: IntroWomenView!
    @IBOutlet private weak var pageProgressView: PageProgressView!
    @IBOutlet private weak var scrollViewContent: UIScrollView!
    @IBOutlet private weak var stackViewContent: UIStackView!
    @IBOutlet private weak var viewLandingImageContainer: UIView!
    
    private weak var pageViewController: UIPageViewController?
    private lazy var viewControllers = [
        IntroLandingViewController.viewController(),
        IntroStepViewController.viewController(configurationData: .first),
        IntroStepViewController.viewController(configurationData: .second),
        IntroStepViewController.viewController(configurationData: .third)
    ]
    
    // MARK: - Constraint
    @IBOutlet private weak var constraintViewLandingImageContainerCenterX: NSLayoutConstraint!
    @IBOutlet private weak var constraintViewLandingImageContainerTop: NSLayoutConstraint!
    
    // MARK: - Properties
    private var router: IntroRouter?
    
    private let lastKnownPage = CurrentValueSubject<Int, Never>(0)
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        sink()
    }
    
    // MARK: - Configuration
    private func configure() {
        configureContentScrollView()
        configureLandingImageContainerView()
        configureSmallLogoImageView()
    }
    
    private func configureContentScrollView() {
        for viewController in viewControllers {
            addChild(viewController)
            
            viewController.view.translatesAutoresizingMaskIntoConstraints = false
            stackViewContent.addArrangedSubview(viewController.view)
            
            NSLayoutConstraint.activate([
                viewController.view.widthAnchor.constraint(equalTo: scrollViewContent.widthAnchor),
                viewController.view.heightAnchor.constraint(equalTo: scrollViewContent.heightAnchor)
            ])
            
            viewController.didMove(toParent: self)
        }
        
        scrollViewContent.delegate = self
    }
    
    private func configureLandingImageContainerView() {
        viewLandingImageContainer.alpha = 0.0
        
        constraintViewLandingImageContainerCenterX.constant = AppRouter.current.window.bounds.width
        if let headerContainerHeight = IntroStepViewController.Step.estimatedHeaderHeight(inside: AppRouter.current.window.bounds) {
            constraintViewLandingImageContainerTop.constant = headerContainerHeight + 32.0
        }
    }
    
    private func configureSmallLogoImageView() {
        imageViewSmallLogo.alpha = 0.0
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoOwnSubjects()
    }
    
    private func sinkIntoOwnSubjects() {
        lastKnownPage
            .filter({ [weak self] in $0 + 1 == self?.viewControllers.count })
            .first()
            .sinkDiscardingValue { [weak self] in
                self?.scrollViewContent.isUserInteractionEnabled = false
                
                let panGestureRecognizer = UIPanGestureRecognizer()
                
                self?.router?.registerGestureRecognizerForTransition(panGestureRecognizer)
                
                self?.view.addGestureRecognizer(panGestureRecognizer)
            }.store(in: &cancellables)
        
        lastKnownPage
            .removeDuplicates()
            .map({ $0 + 1 })
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: pageProgressView.markPageAsActive(_:))
            .store(in: &cancellables)
    }
    
    // MARK: - Updates
    private func goToNextPage() {
        let targetContentOffset = CGPoint(x: CGFloat(lastKnownPage.value + 1) * scrollViewContent.bounds.width, y: 0.0)
        
        guard targetContentOffset.x < scrollViewContent.contentSize.width else {
            return
        }
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.scrollViewContent.setContentOffset(targetContentOffset, animated: false)
        } completion: { [weak self] _ in
            self?.updateLastKnownPage()
        }
    }
    
    private func updateLastKnownPage() {
        let currentPage = Int(scrollViewContent.contentOffset.x / scrollViewContent.bounds.width)
        
        lastKnownPage.value = currentPage
        if currentPage > 0 {
            PreferencesStore.setIntroAsDisplayed()
        }
    }
    
    // MARK: - Actions
    @IBAction private func actionButtonTapped(_ sender: Any) {
        if lastKnownPage.value >= viewControllers.count - 1 {
            router?.navigateToAuth()
        } else {
            goToNextPage()
        }
    }
}

// MARK: - Protocol conformance
// MARK: Navigable
extension IntroViewController: Navigable {
    static var storyboardScene: StoryboardScene {
        .intro
    }
}

// MARK: Routable
extension IntroViewController: Routable {
    typealias RouterType = IntroRouter
    
    func assignRouter(_ router: IntroRouter) {
        self.router = router
    }
}

// MARK: UIScrollViewDelegate
extension IntroViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x <= Double(lastKnownPage.value) * scrollView.bounds.width {
            let targetContentOffset = CGPoint(x: Double(lastKnownPage.value) * scrollView.bounds.width, y: 0.0)
            scrollView.setContentOffset(targetContentOffset, animated: false)

            return
        }
        
        if lastKnownPage.value == 0 {
            if scrollView.contentOffset.x >= scrollView.bounds.width {
                imageViewSmallLogo.alpha = 1.0
                viewLandingImageContainer.alpha = 1.0
            } else if scrollView.contentOffset.x <= scrollView.bounds.width / 2.0 {
                imageViewSmallLogo.alpha = 0.0
                viewLandingImageContainer.alpha = 0.0
            } else {
                let progress = min(1.0, max(0.0, (scrollView.contentOffset.x - scrollView.bounds.width / 2.0) / (scrollView.bounds.width / 2.0)))
                
                imageViewSmallLogo.alpha = progress
                viewLandingImageContainer.alpha = progress
            }
            
            let progress = min(1.0, max(0.0, scrollView.contentOffset.x / scrollView.bounds.width))
            
            constraintViewLandingImageContainerCenterX.constant = AppRouter.current.window.bounds.width * (1.0 - progress)
        } else {
            constraintViewLandingImageContainerCenterX.constant = 0.0
        }
        
        let animationProgress = (scrollView.contentOffset.x - scrollView.bounds.width) / (scrollView.contentSize.width - (scrollView.bounds.width * 2.0))
        introWomenView.updateProgress(animationProgress)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let targetX = targetContentOffset.pointee.x
        
        if targetX <= Double(lastKnownPage.value) * scrollView.bounds.width {
            targetContentOffset.pointee = CGPoint(x: Double(lastKnownPage.value) * scrollView.bounds.width, y: 0.0)
        }
    }
    
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        false
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if(decelerate) {
            return
        }
        
        updateLastKnownPage()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateLastKnownPage()
    }
}
