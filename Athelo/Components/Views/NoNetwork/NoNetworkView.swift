//
//  NoNetworkView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 31/05/2022.
//

import UIKit

final class NoNetworkView: UIView {
    // MARK: - Outlets
    @IBOutlet private weak var imageViewDecoration: UIImageView!
    @IBOutlet private weak var viewContainer: UIView!
    
    // MARK: - View lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configure()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateDecorationImageViewMaskLayer()
    }
    
    // MARK: - Configuration
    private func configure() {
        configureContainerView()
    }
    
    private func configureContainerView() {
        viewContainer.layer.cornerRadius = 20.0
        viewContainer.layer.masksToBounds = true
    }
    
    // MARK: - Updates
    private func updateDecorationImageViewMaskLayer() {
        
        if imageViewDecoration.layer.mask == nil {
            let gradientLayer = CAGradientLayer()
            
            gradientLayer.locations = [0.0, 0.2, 1.0]
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
            
            gradientLayer.colors = [
                UIColor.clear.cgColor,
                UIColor.white.withAlphaComponent(0.2).cgColor,
                UIColor.white.withAlphaComponent(0.2).cgColor
            ]
            
            imageViewDecoration.layer.mask = gradientLayer
        }
        
        imageViewDecoration.layer.mask?.frame = imageViewDecoration.bounds
    }
}
