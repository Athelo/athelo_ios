//
//  HeadlineCollectionViewCell.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 10/06/2022.
//

import UIKit

typealias HeadlineDecorationData = HeadlineCollectionViewCell.DecorationData

final class HeadlineCollectionViewCell: UICollectionViewCell {
    // MARK: - Constants
    struct DecorationData {
        let headline: String
    }
    
    // MARK: - Outlets
    @IBOutlet private weak var labelHeadline: UILabel!
}

// MARK: - Protocol conformance
// MARK: ConfigurableCell
extension HeadlineCollectionViewCell: ConfigurableCell {
    typealias DataType = HeadlineDecorationData
    
    func configure(_ item: HeadlineDecorationData, indexPath: IndexPath) {
        labelHeadline.text = item.headline
    }
}
