//
//  SmallActionCollectionViewCell.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 13/07/2022.
//

import UIKit

protocol SmallActionCollectionViewCellDelegate: AnyObject {
    func smallActionCollectionViewCellDelegateAsksToPerformAction(_ cell: SmallActionCollectionViewCell)
}

final class SmallActionCollectionViewCell: UICollectionViewCell {
    // MARK: - Outlets
    @IBOutlet private weak var buttonAction: UIButton!
    
    // MARK: - Properties
    private weak var delegate: SmallActionCollectionViewCellDelegate?
    
    // MARK: - View lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configure()
    }
    
    // MARK: - Public API
    func assignDelegate(_ delegate: SmallActionCollectionViewCellDelegate) {
        self.delegate = delegate
    }
    
    // MARK: - Configuration
    private func configure() {
        configureActionButton()
    }
    
    private func configureActionButton() {
        buttonAction.titleLabel?.font = .withStyle(.subtitle)
    }
    
    // MARK: - Actions
    @IBAction private func actionButtonTapped(_ sender: Any) {
        delegate?.smallActionCollectionViewCellDelegateAsksToPerformAction(self)
    }
}

extension SmallActionCollectionViewCell: ConfigurableCell {
    struct ConfigurationData {
        let title: String
        let icon: UIImage?
    }
    
    typealias DataType = ConfigurationData
    
    func configure(_ item: ConfigurationData, indexPath: IndexPath) {
        buttonAction.setTitle(item.title, for: .normal)
        if let icon = item.icon {
            buttonAction.setImage(icon, for: .normal)
            
            buttonAction.imageEdgeInsets = UIEdgeInsets(left: -8.0, right: 8.0)
            buttonAction.contentEdgeInsets.left = 24.0
        } else {
            buttonAction.imageEdgeInsets = .zero
            buttonAction.contentEdgeInsets.left = 16.0
        }
    }
}
