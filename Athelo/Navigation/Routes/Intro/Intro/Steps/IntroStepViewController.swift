//
//  IntroStepViewController.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 01/06/2022.
//

import UIKit

final class IntroStepViewController: BaseViewController {
    // MARK: - Constants
    enum Step: CaseIterable {
        case first
        case second
        case third
        
        var next: Step? {
            guard let currentStepIndex = Step.allCases.firstIndex(of: self) else {
                return nil
            }
            
            return Step.allCases[safe: currentStepIndex + 1]
        }
        
        static func estimatedHeaderHeight(inside frame: CGRect) -> CGFloat? {
            let boundingSize = CGSize(width: frame.width - 32.0, height: .greatestFiniteMagnitude)
            let headerFont = UIFont.withStyle(.intro)
            
            return Step.allCases.map({ NSString(string: $0.title) }).map({ $0.boundingRect(with: boundingSize, options: [.usesLineFragmentOrigin], attributes: [.font: headerFont], context: nil).height }).max()
        }
    }
    
    // MARK: - Outlets
    @IBOutlet private weak var labelHeader: UILabel!
    @IBOutlet private weak var viewHeaderContainer: UIView!
    
    // MARK: - Constraints
    @IBOutlet private weak var constraintViewHeaderContainerHeight: NSLayoutConstraint!
    
    // MARK: - Constants
    private(set) var step: Step?
    
    // MARK: - View lifecycle {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
    }
    
    // MARK: - Configuration
    private func configure() {
        configureHeaderContainerView()
        configureHeaderLabel()
        configureOwnView()
    }
    
    private func configureHeaderContainerView() {
        if let headerContentHeight = Step.estimatedHeaderHeight(inside: AppRouter.current.window.bounds) {
            constraintViewHeaderContainerHeight.constant = headerContentHeight
        }
    }
    
    private func configureHeaderLabel() {
        labelHeader.text = step?.title
    }
    
    private func configureOwnView() {
        view.backgroundColor = .clear
    }
}

// MARK: - Protocol conformance
// MARK: Configurable
extension IntroStepViewController: Configurable {
    typealias ConfigurationDataType = Step
    
    func assignConfigurationData(_ configurationData: Step) {
        step = configurationData
    }
}

// MARK: Navigable
extension IntroStepViewController: Navigable {
    static var storyboardScene: StoryboardScene {
        .intro
    }
}

// MARK: Helper extensions
fileprivate extension IntroStepViewController.Step {
    var title: String {
        switch self {
        case .first:
            return "intro.step.first".localized()
        case .second:
            return "intro.step.second".localized()
        case .third:
            return "intro.step.third".localized()
        }
    }
}
