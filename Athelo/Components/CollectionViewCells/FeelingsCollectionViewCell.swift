//
//  FeelingsCollectionViewCell.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 25/07/2022.
//

import UIKit

final class FeelingsCollectionViewCell: UICollectionViewCell {
    // MARK: - Outlets
    @IBOutlet private weak var labelEmoji: UILabel!
    @IBOutlet private weak var labelFeeling: UILabel!
}

// MARK: Protocol conformance
// MARK: - ConfigurableCell
extension FeelingsCollectionViewCell: ConfigurableCell {
    func configure(_ item: FeelingScale, indexPath: IndexPath) {
        labelEmoji.text = item.emoji
        labelFeeling.text = "(\(item.descriptor))"
    }
}
