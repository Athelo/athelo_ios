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
    @IBOutlet private weak var textViewLegal: UITextView!
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
        configureLegalTextView()
        
        configureContainerView()
    }
    
    private func configureContainerView() {
        guard signUpNavigationController == nil else {
            return
        }
        
        let navigationController = BaseNavigationController()
        
        navigationController.makeNavigationBarTranslucent()
        
        let router = SignUpRouter(navigationController: navigationController, updateEventsSubject: router?.authenticationUpdateEventsSubject)
        let viewController = SignUpViewController.viewController(router: router)
        
        viewController.additionalSafeAreaInsets = UIEdgeInsets(bottom: textViewLegal.bounds.height + 32.0)
        
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
    
    private func configureLegalTextView() {
        textViewLegal.removePadding()
        
        textViewLegal.text = "auth.legal".localized()
        guard let attributedText = textViewLegal.attributedText, !attributedText.string.isEmpty else {
            return
        }
        
        let updatedAttributedText = NSMutableAttributedString(attributedString: attributedText)
        for identifier in LabelIdentifiers.allCases {
            let range = (attributedText.string as NSString).range(of: identifier.boundString)
            guard range.location != NSNotFound else {
                continue
            }
            
            guard let customURL = URL(string: "athelo://\(identifier.rawValue)") else {
                continue
            }
            
            updatedAttributedText.addAttribute(.link, value: customURL, range: range)
            updatedAttributedText.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
//            updatedAttributedText.addAttribute(.foregroundColor, value: UIColor.withStyle(.purple80627F), range: range)
        }
        
        textViewLegal.attributedText = updatedAttributedText
        
        weak var weakSelf = self
        let tapGestureRecognizer = UITapGestureRecognizer(target: weakSelf, action: #selector(handleLegalTextViewTap(_:)))
        
        textViewLegal.addGestureRecognizer(tapGestureRecognizer)
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
                    self?.textViewLegal.alpha = value
                }
            }.store(in: &cancellables)
    }
    
    // MARK: - Actions
    @objc private func handleLegalTextViewTap(_ sender: Any) {
        guard let tapGestureRecognizer = sender as? UITapGestureRecognizer else {
            return
        }
        
        let tapLocation = tapGestureRecognizer.location(in: textViewLegal)
        guard let textPosition = textViewLegal.closestPosition(to: tapLocation),
              let positionStyling = textViewLegal.textStyling(at: textPosition, in: .forward),
              let url = positionStyling[.link] as? URL else {
            return
        }
        
        guard url.scheme == "athelo",
              let host = url.host,
              let identifier = LabelIdentifiers(rawValue: host) else {
            return
        }
        
        guard let navigationController = signUpNavigationController else {
            return
        }
        
        let router = LegalRouter(navigationController: navigationController)
        let viewController = LegalViewController.viewController(configurationData: identifier.legalConfiguration, router: router)
        
        navigationController.pushViewController(viewController, animated: true)
        
        let shouldRestoreLegal = !textViewLegal.isHidden
        textViewLegal.isHidden = true
        
        viewController.assignOnDisapperAction { [weak self] in
            if shouldRestoreLegal {
                self?.textViewLegal.isHidden = false
            }
        }
    }
}

// MARK: - Protocol conformance
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
