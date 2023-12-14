//
//  NewsListItemTableViewCell.swift
//  Athelo
//
//  Created by FS-EMP-2 on 2023-11-15.
//

import UIKit
import RichTextRenderer
import Contentful

class NewsListItemTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var newsImageView: UIImageView!
    @IBOutlet private weak var viewNoPhoto: UIView!
    @IBOutlet private weak var loadingViewPhoto: LoadingView!
    @IBOutlet private weak var imageViewNoPhoto: UIImageView!
    // MARK: - View lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        configure()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16))
        contentView.cornerRadius = 20
    }
    
    // MARK: - Configuration
    private func configure() {
        configureNoPhotoView()
    }
    
    private func configureNoPhotoView() {
        viewNoPhoto.backgroundColor = .withStyle(.greenB5DE71).withAlphaComponent(0.18)
    }
    
    func configureCell(contentfulData: ContentfulNewsData) {
        
        self.titleLabel.text = contentfulData.title
        
        // Default configuration of the renderer.
        var configuration = DefaultRendererConfiguration()
        
        let renderer = RichTextDocumentRenderer(configuration: configuration)
        
        if let body = contentfulData.body {
            self.descriptionLabel.text = renderer.render(document: body).string
//            self.descriptionLabel.attributedText = renderer.render(document: body)
        }
        
        if let url = contentfulData.image?.url {
            viewNoPhoto.isHidden = true
            loadingViewPhoto.isHidden = false
            
            newsImageView.displayLoadableImage(LoadableImageData.url(url)) { [weak self] result in
                self?.loadingViewPhoto.isHidden = true
                self?.viewNoPhoto.isHidden = !result
            }
        } else {
            newsImageView.image = nil
            loadingViewPhoto.isHidden = true
            
            newsImageView.image = RendererUtility.renderNoImagePlaceholder(forHeight: 136.0)
            viewNoPhoto.isHidden = false
        }
    }
    
    var viewBackground = UIView()
    var viewBackgroundBorder = UIView()
}

struct ImageViewProvider: ResourceLinkBlockViewProviding {
    func view(for resource: Contentful.Link, context: [CodingUserInfoKey : Any]) -> RichTextRenderer.ResourceLinkBlockViewRepresentable? {
        
        switch resource {
        case .entryDecodable(_):
            return nil
            
        case .entry:
            return nil
            
        case .asset(let asset):
            guard asset.file?.details?.imageInfo != nil else { return nil }
            
            let imageView = ResourceLinkBlockImageView(asset: asset)
            
            imageView.backgroundColor = .gray
            imageView.setImageToNaturalHeight()
            return imageView
        default:
            return nil
        }
    }
}
