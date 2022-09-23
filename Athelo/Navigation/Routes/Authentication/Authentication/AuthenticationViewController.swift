//
//  AuthenticationViewController.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 01/06/2022.
//

import Combine
import UIKit

final class AuthenticationViewController: BaseViewController {
    // MARK: Constants
    private enum LabelIdentifiers: String, CaseIterable {
        case privacyPolicy
        case termsOfService
        
        var boundString: String {
            switch self {
            case .privacyPolicy:
                return "auth.legal.pp".localized()
            case .termsOfService:
                return "auth.legal.tos".localized()
            }
        }
        
        var legalConfiguration: LegalConfigurationData {
            switch self {
            case .privacyPolicy:
                let privacyPolicy = ConstantsStore.applicationData()?.privacy
                return .init(title: "navigation.privacypolicy".localized(), source: privacyPolicy?.isEmpty == false ? .text(privacyPolicy!) : .publisher(
                    ConstantsStore.applicationDataPublisher()
                        .tryMap({
                            guard let privacyPolicy = $0.privacy, !privacyPolicy.isEmpty else {
                                throw CommonError.missingContent
                            }
                            
                            return privacyPolicy
                        })
                        .eraseToAnyPublisher()
                ))
            case .termsOfService:
                let termsOfService = ConstantsStore.applicationData()?.termsOfUse
                return .init(title: "navigation.termsofservice".localized(), source: termsOfService?.isEmpty == false ? .text(termsOfService!) : .publisher(
                    ConstantsStore.applicationDataPublisher()
                        .tryMap({
                            guard let termsOfService = $0.termsOfUse, !termsOfService.isEmpty else {
                                throw CommonError.missingContent
                            }
                            
                            return termsOfService
                        })
                        .eraseToAnyPublisher()
                ))
            }
        }
    }
    
    // MARK: - Outlets
    @IBOutlet private weak var labelLegal: InteractableLabel!
    @IBOutlet private weak var viewContainer: UIView!
    
    private var signUpNavigationController: BaseNavigationController?
    
    // MARK: - Properties
    private var router: AuthenticationRouter?
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        sink()
    }
    
    // MARK: - Configuration
    private func configure() {
        configureContainerView()
        configureLegalLabel()
    }
    
    private func configureContainerView() {
        guard signUpNavigationController == nil else {
            return
        }
        
        let navigationController = BaseNavigationController()
        
        navigationController.makeNavigationBarTranslucent()
        
        let router = SignUpRouter(navigationController: navigationController, updateEventsSubject: router?.authenticationUpdateEventsSubject)
        let viewController = SignUpViewController.viewController(router: router)
        
        viewController.additionalSafeAreaInsets = UIEdgeInsets(bottom: labelLegal.bounds.height + 32.0)
        
        navigationController.setViewControllers([viewController], animated: false)
        
        addChild(navigationController)
        
        navigationController.view.translatesAutoresizingMaskIntoConstraints = false
        
        navigationController.view.clipsToBounds = false
        
        viewContainer.addSubview(navigationController.view)
        
        NSLayoutConstraint.activate([
            navigationController.view.topAnchor.constraint(equalTo: viewContainer.topAnchor),
            navigationController.view.bottomAnchor.constraint(equalTo: viewContainer.bottomAnchor),
            navigationController.view.leftAnchor.constraint(equalTo: viewContainer.leftAnchor),
            navigationController.view.rightAnchor.constraint(equalTo: viewContainer.rightAnchor)
        ])
        
        navigationController.didMove(toParent: self)
        
        signUpNavigationController = navigationController
    }
    
    private func configureLegalLabel() {
        guard let text = labelLegal.text, !text.isEmpty else {
            return
        }
        
        labelLegal.assignDelegate(self)
        
        var foundRanges: [NSRange] = []
        LabelIdentifiers.allCases.forEach({
            labelLegal.markSubstringAsInteractable($0.boundString, identifier: $0.rawValue)
            
            if let range = (labelLegal.text as? NSString)?.range(of: $0.boundString) {
                foundRanges.append(range)
            }
        })
        
        guard !foundRanges.isEmpty else {
            return
        }
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineHeightMultiple = 1.24
        paragraph.alignment = .center
        
        let attributedString = NSMutableAttributedString(string: text, attributes: [
            .paragraphStyle: paragraph
        ])
        
        for foundRange in foundRanges {
            attributedString.addAttribute(.foregroundColor, value: UIColor.withStyle(.black), range: foundRange)
        }
        
        labelLegal.attributedText = attributedString
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoRouter()
    }
    
    private func sinkIntoRouter() {
        router?.authenticationUpdateEventsSubject
            .compactMap({ $0.modelState })
            .receive(on: DispatchQueue.main)
            .filter({ [weak self] _ in self?.view.window != nil })
            .sink { [weak self] in
                switch $0 {
                case .error(let error):
                    AppRouter.current.windowOverlayUtility.hideLoadingView()
                    
                    if !(error is AuthenticationPingError) && !((error as? ThirdPartyAuthenticationError)?.isSheetDismissedError == true) {
                        self?.displayError(error)
                    }
                case .loaded:
                    AppRouter.current.windowOverlayUtility.hideLoadingView()
                case .loading:
                    AppRouter.current.windowOverlayUtility.displayLoadingView()
                case .initial:
                    break
                }
            }.store(in: &cancellables)
        
        router?.authenticationUpdateEventsSubject
            .compactMap({ $0.legalVisibility })
            .removeDuplicates()
            .map({ $0 ? 1.0 : 0.0 })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                UIView.animate(withDuration: 0.1, delay: 0.0, options: [.beginFromCurrentState]) {
                    self?.labelLegal.alpha = value
                }
            }.store(in: &cancellables)
    }
}

// MARK: - Protocol conformance
// MARK: InteractableLabelDelegate
extension AuthenticationViewController: InteractableLabelDelegate {
    func interactableLabel(_ label: InteractableLabel, selectedTextWithIdentifier identifier: String) {
        guard let identifier = LabelIdentifiers(rawValue: identifier),
            let navigationController = signUpNavigationController else {
            return
        }
        
        let router = LegalRouter(navigationController: navigationController)
        let viewController = LegalViewController.viewController(configurationData: identifier.legalConfiguration, router: router)
        
        navigationController.pushViewController(viewController, animated: true)
        
        let shouldRestoreLegal = !labelLegal.isHidden
        labelLegal.isHidden = true
        
        viewController.assignOnDisapperAction { [weak self] in
            if shouldRestoreLegal {
                self?.labelLegal.isHidden = false
            }
        }
    }
}

// MARK: Navigable
extension AuthenticationViewController: Navigable {
    static var storyboardScene: StoryboardScene{
        .authentication
    }
}

// MARK: Routable
extension AuthenticationViewController: Routable {
    typealias RouterType = AuthenticationRouter
    
    func assignRouter(_ router: AuthenticationRouter) {
        self.router = router
    }
}
