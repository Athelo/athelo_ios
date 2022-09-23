//
//  FilterTableViewCell.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 07/07/2022.
//

import UIKit

struct FilterCellDecorationData {
    let optionName: String
    let isSelected: Bool
}

final class FilterTableViewCell: UITableViewCell {
    // MARK: - Outlets
    @IBOutlet private weak var imageViewCheckmark: UIImageView!
    @IBOutlet private weak var labelOptionName: UILabel!
    @IBOutlet private weak var viewSelectionContainer: UIView!
    
    // MARK: - View lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configure()
    }
    
    // MARK: - Configuration
    private func configure() {
        configureCheckmarkImageView()
    }
    
    private func configureCheckmarkImageView() {
        imageViewCheckmark.image = imageViewCheckmark.image?.withRenderingMode(.alwaysTemplate)
    }
}

// MARK: - Protocol conformance
// MARK: ConfigurableCell
extension FilterTableViewCell: ConfigurableCell {
    typealias DataType = FilterCellDecorationData
    
    func configure(_ item: FilterCellDecorationData, indexPath: IndexPath) {
        viewSelectionContainer.backgroundColor = item.isSelected ? .withStyle(.purple623E61) : .withStyle(.lightGray)
        imageViewCheckmark.isHidden = !item.isSelected
        
        labelOptionName.text = item.optionName
    }
}
