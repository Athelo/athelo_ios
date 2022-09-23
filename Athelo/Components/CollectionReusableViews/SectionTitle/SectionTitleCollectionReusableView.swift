//
//  SectionTitleCollectionReusableView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 10/06/2022.
//

import UIKit

typealias SectionTitleDecorationData = SectionTitleCollectionReusableView.DecorationData

final class SectionTitleCollectionReusableView: UICollectionReusableView {
    // MARK: - Constants
    struct DecorationData {
        let title: String
        let font: UIFont
        
        init(title: String, font: UIFont = .withStyle(.subheading)) {
            self.title = title
            self.font = font
        }
    }
    
    @IBOutlet private weak var labelTitle: UILabel!
}

// MARK: - Protocol conformance
// MARK: ConfigurableCell
extension SectionTitleCollectionReusableView: ConfigurableCell {
    typealias DataType = SectionTitleDecorationData
    
    func configure(_ item: SectionTitleDecorationData, indexPath: IndexPath) {
        labelTitle.text = item.title
        labelTitle.font = item.font
    }
}
