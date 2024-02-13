//
//  ErrorView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 08/06/2022.
//

import Combine
import CombineCocoa
import UIKit

struct InfoMessageData {
    enum MessageType {
        case error
        case plain
        case success
        case successSecondery
        case fail
    }
    
    let text: String
    let type: MessageType
}

final class InfoMessageView: UIView {
    // MARK: - Outlets
    @IBOutlet private weak var buttonDismiss: UIButton!
    @IBOutlet private weak var imageViewDecoration: UIImageView!
    @IBOutlet private weak var labelMessage: UILabel!
    @IBOutlet private weak var viewContainer: UIView!
    @IBOutlet private weak var viewOverlay: UIView!
    
    // MARK: - Properties
    var dismissButtonTapPublisher: AnyPublisher<Void, Never> {
        buttonDismiss.tapPublisher
            .eraseToAnyPublisher()
    }
    
    // MARK: - View lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configure()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateDecorationImageViewMaskLayer()
    }
    
    // MARK: - Public API
    func displayMessage(_ message: InfoMessageData) {
        displayMessage(message.text, type: message.type)
    }
    
    func displayMessage(_ message: String, type: InfoMessageData.MessageType) {
        labelMessage.textColor = type.textColor
        labelMessage.text = message
        
        viewOverlay.backgroundColor = type.backgroundColor
        
        buttonDismiss.tintColor = type.textColor
        buttonDismiss.setImage(UIImage(named: "close")?.withRenderingMode(.alwaysTemplate), for: .normal)
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

// MARK: - Helper extensions
private extension InfoMessageData.MessageType {
    var backgroundColor: UIColor {
        switch self {
        case .error:
            return .withStyle(.redFF4D4D)
        case .success:
            return .withStyle(.green8FCC25)
        case .plain, .successSecondery, .fail:
            return .clear
        }
    }
    
    var textColor: UIColor {
        switch self {
        case .error, .success:
            return .withStyle(.white)
        case .plain:
            return .withStyle(.gray)
        case .successSecondery:
            return .withStyle(.olivaceous)
        case .fail:
            return .withStyle(.redFF4D4D)
        }
    }
}
