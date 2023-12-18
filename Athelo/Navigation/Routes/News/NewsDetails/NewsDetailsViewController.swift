//
//  NewsDetailsViewController.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 06/07/2022.
//

import Combine
import SwiftDate
import UIKit
import RichTextRenderer
import SafariServices

final class NewsDetailsViewController: BaseViewController, UITextViewDelegate {
    // MARK: - Outlets
    @IBOutlet private weak var buttonArticle: UIButton!
    @IBOutlet private weak var imageViewPhoto: UIImageView!
    @IBOutlet private weak var labelDate: UILabel!
    @IBOutlet private weak var loadingViewPhoto: LoadingView!
    @IBOutlet private weak var textViewBody: UITextView!
    @IBOutlet private weak var textViewTitle: UITextView!
    @IBOutlet private weak var viewButtonBackground: UIView!
    @IBOutlet private weak var viewDateContainer: UIView!
    @IBOutlet private weak var viewHeaderContainer: UIView!
    @IBOutlet private weak var bottomImageView: UIImageView!
    private weak var buttonFavorite: UIButton?
    
    // MARK: - Constraints
    @IBOutlet private weak var constraintStackViewContentBottom: NSLayoutConstraint!
    
    // MARK: - Properties
    private let viewModel = NewsDetailsViewModel()
    private var router: NewsDetailsRouter?
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        bottomImageView.visiblity(gone: true)
        buttonArticle.visiblity(gone: true)
        configure()
        sink()
    }
    
    // MARK: - Configuration
    private func configure() {
        configureBodyTextView()
        configureFavoriteNavbarButton()
        configureOwnView()
        configureTitleTextView()
    }
    
    private func configureBodyTextView() {
        textViewBody.removePadding()
    }
    
    private func configureFavoriteNavbarButton() {
        guard buttonFavorite == nil else {
            return
        }
        
        let button = UIButton()
        
        weak var weakSelf = self
        button.addTarget(weakSelf, action: #selector(favoriteButtonTapped(_:)), for: .touchUpInside)
        button.setImage(UIImage(named: "heart"), for: .normal)
        
        let barButtonItem = UIBarButtonItem(customView: button)
        
        navigationItem.rightBarButtonItem = barButtonItem
        
        buttonFavorite = button
    }
    
    private func configureOwnView() {
        title = "navigation.article".localized()
    }
    
    private func configureTitleTextView() {
        textViewTitle.removePadding()
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoViewModel()
    }
    
    private func sinkIntoViewModel() {
        bindToViewModel(viewModel, cancellables: &cancellables)
        
        viewModel.$newsData
            .compactMap({ $0?.contentfulData })
            .receive(on: DispatchQueue.main)
            .map({ value -> URL? in
                value.image?.url
            })
            .removeDuplicates()
            .sink { [weak self] in
                if let url = $0 {
                    self?.loadingViewPhoto.isHidden = false
                    self?.imageViewPhoto.isHidden = false
                    
                    self?.imageViewPhoto.sd_setImage(with: url, completed: { [weak self] image, _, _, _ in
                        self?.loadingViewPhoto.isHidden = true
                        self?.imageViewPhoto.isHidden = image == nil
                    })
                    
                } else {
                    self?.loadingViewPhoto.isHidden = true
                    self?.imageViewPhoto.isHidden = true
                }
            }.store(in: &cancellables)
        
        
        viewModel.$newsData
            .compactMap({ $0?.contentfulData })
            .receive(on: DispatchQueue.main)
            .map({ value -> URL? in
                value.bottomLogo?.url
            })
            .removeDuplicates()
            .sink { [weak self] in
                if let url = $0 {
                    self?.bottomImageView.sd_setImage(with: url, completed: { [weak self] image, _, _, _ in
                        self?.bottomImageView.isHidden = image == nil
                    })
                } else {
                    self?.bottomImageView.isHidden = true
                }
            }.store(in: &cancellables)
        
        viewModel.$newsData
            .compactMap({ $0?.contentfulData })
            .map({ $0.title })
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.textViewTitle.text = $0
                
                if $0.isEmpty == false {
                    self?.updateTitleTextViewMask()
                }
            }.store(in: &cancellables)
        
        viewModel.$newsData
            .compactMap({ $0?.contentfulData })
            .map({ $0.updatedAt?.toString(.custom("MMM dd, yyyy")) })
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.labelDate.text = $0
                self?.updateTitleTextViewMask()
            }.store(in: &cancellables)
        
        viewModel.$newsData
            .compactMap({ $0?.contentfulData })
            .map({ $0.body })
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                // Default configuration of the renderer.
                var configuration = DefaultRendererConfiguration()
                let renderer = RichTextDocumentRenderer(configuration: configuration)
                
                if let body = $0 {
                    self?.textViewBody.attributedText = renderer.render(document: body)
                }
                self?.textViewBody.delegate = self
                self?.textViewBody.isHidden = !(self?.textViewBody.text.isEmpty == false)
            }.store(in: &cancellables)
//        self.viewButtonBackground.isHidden = true
        
//        viewModel.$newsData
//            .map({ !($0?.contentURL != nil) })
//            .removeDuplicates()
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] in
//                self?.buttonArticle.isHidden = $0
//                self?.viewButtonBackground.isHidden = $0
//                
//                self?.constraintStackViewContentBottom.constant = -(16.0 + ($0 ? 0.0 : ((self?.buttonArticle.frame.height ?? 0.0) + 16.0)))
//            }.store(in: &cancellables)
        
//        viewModel.$newsData
//            .compactMap({ $0 })
//            .map({ $0.isFavourite })
//            .removeDuplicates()
//            .map({ $0 ? "heartSolid" : "heart" })
//            .receive(on: DispatchQueue.main)
//            .map({ UIImage(named: $0) })
//            .sink { [weak button = buttonFavorite] in
//                button?.setImage($0, for: .normal)
//            }.store(in: &cancellables)
    }
    
    // MARK: - Updates
    
    func textView(_ textView: UITextView, shouldInteractWith url: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        let config = SFSafariViewController.Configuration()
        let vc = SFSafariViewController(url: url, configuration: config)
        present(vc, animated: true)
        return false
    }
    
    private func updateTitleTextViewMask() {
        if self.labelDate.text?.isEmpty == true {
            guard !textViewTitle.textContainer.exclusionPaths.isEmpty else {
                return
            }
            
            textViewTitle.textContainer.exclusionPaths = []
            textViewTitle.invalidateIntrinsicContentSize()
        } else {
            view.layoutIfNeeded()
            
            let exclusionPath = UIBezierPath(rect: viewDateContainer.frame)
            textViewTitle.textContainer.exclusionPaths = [exclusionPath]
        }
    
        // MARK: - Workaround based on: https://stackoverflow.com/questions/48079071/
        if !textViewTitle.textContainer.exclusionPaths.isEmpty {
            let titleText = textViewTitle.text
            textViewTitle.text = " "
            textViewTitle.text = titleText
        }
    }
    
    // MARK: - Actions
    @IBAction private func favoriteButtonTapped(_ sender: Any) {
//        viewModel.switchFavoriteState()
    }
    
    @IBAction private func readFullArticleButtonTapped(_ sender: Any) {
        guard let url = viewModel.newsData?.contentURL else {
            return
        }
        
        router?.displayURL(url)
    }
}

// MARK: - Protocol conformance
// MARK: Configurable
extension NewsDetailsViewController: Configurable {
    typealias ConfigurationDataType = ModelConfigurationData<NewsData>
    
    func assignConfigurationData(_ configurationData: ModelConfigurationData<NewsData>) {
        viewModel.assignConfigurationData(configurationData)
    }
}

// MARK: Navigable
extension NewsDetailsViewController: Navigable {
    static var storyboardScene: StoryboardScene {
        .news
    }
}

// MARK: Routable
extension NewsDetailsViewController: Routable {
    func assignRouter(_ router: NewsDetailsRouter) {
        self.router = router
    }
}

extension UIView {
    
    func visiblity(gone: Bool, dimension: CGFloat = 0.0, attribute: NSLayoutConstraint.Attribute = .height) -> Void {
        if let constraint = (self.constraints.filter{$0.firstAttribute == attribute}.first) {
            constraint.constant = gone ? 0.0 : dimension
            self.layoutIfNeeded()
            self.isHidden = gone
        }
    }
}
