//
//  PillCollectionViewCell.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 21/07/2022.
//

import UIKit

typealias PillCellDecorationData = PillCollectionViewCell.DecorationData

protocol PillCollectionViewCellDelegate: AnyObject {
    func pillCollectionViewCell(_ cell: PillCollectionViewCell, asksToRemoveItemWithIdentifier itemIdentifier: Int)
}

final class PillCollectionViewCell: UICollectionViewCell {
    // MARK: - Outlets
    @IBOutlet private weak var buttonRemove: UIButton!
    @IBOutlet private weak var labelTitle: UILabel!
    
    // MARK: - Constraints
    @IBOutlet private weak var constraintViewContentWidth: NSLayoutConstraint!
    
    // MARK: - Properties
    private var itemIdentifier: Int?
    
    private weak var delegate: PillCollectionViewCellDelegate?
    
    // MARK: - View lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureOwnView()
    }
    
    // MARK: - Public API
    func assignDelegate(_ delegate: PillCollectionViewCellDelegate) {
        self.delegate = delegate
    }
    
    func assignWidthBoundary(_ widthBoundary: CGFloat) {
        constraintViewContentWidth.constant = widthBoundary
    }
    
    // MARK: - Configuration
    private func configure() {
        configureOwnView()
    }
    
    private func configureOwnView() {
        constraintViewContentWidth.constant = UIScreen.main.bounds.size.width
    }
    
    // MARK: - Actions
    @IBAction private func removeButtonTapped(_ sender: Any) {
        guard let itemIdentifier = itemIdentifier else {
            return
        }

        delegate?.pillCollectionViewCell(self, asksToRemoveItemWithIdentifier: itemIdentifier)
    }
}

// MARK: - Protocol conformance
// MARK: ConfigurableCell
extension PillCollectionViewCell: ConfigurableCell {
    struct DecorationData {
        let displaysRemoveAction: Bool
        let itemIdentifier: Int?
        let text: String
        
        init(text: String, itemIdentifier: Int? = nil, displaysRemoveAction: Bool = false) {
            self.displaysRemoveAction = displaysRemoveAction
            self.itemIdentifier = itemIdentifier
            self.text = text
        }
    }
    
    func configure(_ item: PillCellDecorationData, indexPath: IndexPath) {
        self.itemIdentifier = item.itemIdentifier
        
        buttonRemove.isHidden = !item.displaysRemoveAction
        labelTitle.text = item.text
    }
}
