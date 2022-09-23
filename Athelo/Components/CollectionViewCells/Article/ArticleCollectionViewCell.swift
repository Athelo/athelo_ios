//
//  ArticleCollectionViewCell.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 06/07/2022.
//

import UIKit

protocol ArticleCellDecorationData {
    var articleCellBody: String? { get }
    var articleCellPhoto: LoadableImageData? { get }
    var articleCellTitle: String? { get }
}

final class ArticleCollectionViewCell: UICollectionViewCell {
    // MARK: - Outlets
    @IBOutlet private weak var imageViewNoPhoto: UIImageView!
    @IBOutlet private weak var imageViewPhoto: UIImageView!
    @IBOutlet private weak var labelBody: UILabel!
    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet private weak var loadingViewPhoto: LoadingView!
    @IBOutlet private weak var viewNoPhoto: UIView!
    
    // MARK: - View lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configure()
    }
    
    // MARK: - Configuration
    private func configure() {
        configureNoPhotoView()
    }
    
    private func configureNoPhotoView() {
        viewNoPhoto.backgroundColor = .withStyle(.greenB5DE71).withAlphaComponent(0.18)
    }
}

// MARK: - Protocol conformance
// MARK: ConfigurableCell
extension ArticleCollectionViewCell: ConfigurableCell {
    typealias DataType = ArticleCellDecorationData
    
    func configure(_ item: DataType, indexPath: IndexPath) {
        if let body = item.articleCellBody, !body.isEmpty {
            labelBody.text = body
            labelBody.isHidden = false
        } else {
            labelBody.isHidden = true
        }
        
        if let title = item.articleCellTitle, !title.isEmpty {
            labelTitle.text = title
            labelTitle.isHidden = false
        } else {
            labelTitle.isHidden = true
        }
        
        if let photo = item.articleCellPhoto {
            viewNoPhoto.isHidden = true
            loadingViewPhoto.isHidden = false
            
            imageViewPhoto.displayLoadableImage(photo) { [weak self] result in
                self?.loadingViewPhoto.isHidden = true
                self?.viewNoPhoto.isHidden = !result
            }
        } else {
            imageViewPhoto.image = nil
            loadingViewPhoto.isHidden = true
            
            imageViewPhoto.image = RendererUtility.renderNoImagePlaceholder(forHeight: 136.0)
            viewNoPhoto.isHidden = false
        }
    }
}
