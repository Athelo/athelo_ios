//
//  TileCollectionViewCell.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 10/06/2022.
//

import SDWebImage
import UIKit

typealias TileDecorationData = TileCollectionViewCell.DecorationData

final class TileCollectionViewCell: UICollectionViewCell {
    // MARK: - Constants
    struct DecorationData {
        enum Style {
            case destructive
            case plain
        }
        
        let hasBackgroundDecoration: Bool
        let icon: LoadableImageData?
        let isActionable: Bool
        let style: Style
        let text: String
        
        init(text: String, style: Style = .plain, icon: LoadableImageData? = nil, isActionable: Bool = false, hasBackgroundDecoration: Bool = false) {
            self.text = text
            self.style = style
            
            self.hasBackgroundDecoration = hasBackgroundDecoration
            self.icon = icon
            self.isActionable = isActionable
        }
    }
    
    // MARK: - Outlets
    @IBOutlet private weak var imageViewChevron: UIImageView!
    @IBOutlet private weak var imageViewIcon: UIImageView!
    @IBOutlet private weak var imageViewWavesBackground: UIImageView!
    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet private weak var viewContentContainer: UIView!
    
    // MARK: - View lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configure()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateWavesBackgroundImageViewMaskLayer()
    }
    
    // MARK: - Configuration
    private func configure() {
        configureContentContainerView()
    }
    
    private func configureContentContainerView() {
        viewContentContainer.layer.masksToBounds = true
        viewContentContainer.layer.cornerRadius = 20.0
    }
    
    // MARK: - Updates
    private func updateWavesBackgroundImageViewMaskLayer() {
        if imageViewWavesBackground.layer.mask == nil {
            let gradientLayer = CAGradientLayer()
            
            gradientLayer.locations = [0.0, 0.2, 1.0]
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
            
            gradientLayer.colors = [
                UIColor.clear.cgColor,
                UIColor.white.withAlphaComponent(0.2).cgColor,
                UIColor.white.withAlphaComponent(0.2).cgColor
            ]
            
            imageViewWavesBackground.layer.mask = gradientLayer
        }
        
        imageViewWavesBackground.layer.mask?.frame = imageViewWavesBackground.bounds
    }
}

// MARK: - Protocol conformance
// MARK: ConfigurableCell
extension TileCollectionViewCell: ConfigurableCell {
    typealias DataType = TileDecorationData
    
    func configure(_ item: TileDecorationData, indexPath: IndexPath) {
        labelTitle.textColor = item.style.titleTextColor
        labelTitle.text = item.text
        
        imageViewIcon.tintColor = item.style.imageTintColor
        if let icon = item.icon {
            imageViewIcon.displayLoadableImage(icon, renderingMode: .alwaysTemplate)
            imageViewIcon.isHidden = false
        } else {
            imageViewIcon.isHidden = true
        }
        
        imageViewChevron.isHidden = !item.isActionable
        imageViewWavesBackground.isHidden = !item.hasBackgroundDecoration
    }
}

// MARK: - Helper extensions
private extension TileDecorationData.Style {
    var imageTintColor: UIColor {
        switch self {
        case .destructive:
            return .withStyle(.redFF0000)
        case .plain:
            return .withStyle(.purple80627F)
        }
    }
    
    var titleTextColor: UIColor {
        switch self {
        case .destructive:
            return .withStyle(.redFF0000)
        case .plain:
            return .withStyle(.gray)
        }
    }
}
